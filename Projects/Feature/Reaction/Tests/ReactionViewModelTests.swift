import Foundation
import Testing

import Dependencies
import DomainInterface

@testable import FeatureReaction

@MainActor
struct ReactionViewModelTests {
    private enum Constants {
        static let groupId = 10
        static let groupName = "성민아 밥먹자"
        static let dateText = "8월 5일 (수)"

        static let myUserId = 1
        static let friendUserId = 2
        static let notUploadedUserId = 4
        static let friendPhotoId = 1
        static let myPhotoId = 501

        static let friendNotUploadedMessage = "아직 친구가 점심을 올리지 않았어요!"
    }

    private static let members: [GroupMember] = [
        GroupMember(
            userId: Constants.myUserId,
            nickname: "나",
            isMine: true,
            photo: GroupMemberPhoto(photoId: Constants.myPhotoId, downloadUrl: "https://example.com/mine")
        ),
        GroupMember(
            userId: Constants.friendUserId,
            nickname: "길동",
            isMine: false,
            photo: GroupMemberPhoto(photoId: Constants.friendPhotoId, downloadUrl: "https://example.com/friend")
        ),
        GroupMember(userId: Constants.notUploadedUserId, nickname: "철수", isMine: false, photo: nil)
    ]

    private func makeViewModel(
        selectedUserId: Int,
        onPhotoDeleted: @escaping () -> Void = {}
    ) -> ReactionViewModel {
        withDependencies {
            $0.deletePhotoUseCase = DeletePhotoUseCase { _ in }
            $0.getCommentsUseCase = GetCommentsUseCase(execute: { _, _ in [] })
            $0.addReactionUseCase = AddReactionUseCase { _ in }
        } operation: {
            ReactionViewModel(
                groupId: Constants.groupId,
                groupName: Constants.groupName,
                dateText: Constants.dateText,
                members: Self.members,
                selectedUserId: selectedUserId,
                onPhotoDeleted: onPhotoDeleted
            )
        }
    }

    @Test("친구가 올린 사진에서는 리액션이 가능하고, 이모지를 누르면 '나'의 로그가 맨 아래에 붙는다")
    func emojiTapAppendsMyReaction() async {
        let viewModel = makeViewModel(selectedUserId: Constants.friendUserId)
        let before = viewModel.selectedItem?.reactions.count ?? 0

        #expect(viewModel.isReactionEnabled)

        await viewModel.emojiTapped(.hot)

        let reactions = viewModel.selectedItem?.reactions ?? []
        #expect(reactions.count == before + 1)
        #expect(reactions.last?.isMine == true)
        #expect(reactions.last?.emoji == .hot)
        #expect(reactions.last?.displayName == ReactionLogEntry.myDisplayName)
        #expect(ReactionEmoji.hot.fallbackYoungCrackComments.contains(reactions.last?.comment ?? ""))
    }

    @Test("내 사진에서는 버튼 바가 비활성이고 이모지 탭이 무시된다")
    func myPhotoDisablesReaction() async {
        let viewModel = makeViewModel(selectedUserId: Constants.myUserId)
        let before = viewModel.selectedItem?.reactions.count ?? 0

        #expect(!viewModel.isReactionEnabled)

        await viewModel.emojiTapped(.drool)

        #expect(viewModel.selectedItem?.reactions.count == before)
    }

    @Test("아직 사진이 올라오지 않은 카드는 비활성이고 미트볼 메뉴도 뜨지 않는다")
    func notUploadedPhotoDisablesReactionAndMenu() {
        let viewModel = makeViewModel(selectedUserId: Constants.notUploadedUserId)

        #expect(!viewModel.isReactionEnabled)
        #expect(viewModel.selectedItem?.showsMenu == false)
        #expect(viewModel.selectedItem?.emptyMessage == Constants.friendNotUploadedMessage)
    }

    @Test("모드는 '적용'을 눌러야 반영되고, 이후 버전 모드는 선택되지 않는다")
    func modeAppliesOnlyOnApply() {
        let viewModel = makeViewModel(selectedUserId: Constants.friendUserId)

        viewModel.modeTapped()
        #expect(viewModel.isModeSheetPresented)

        viewModel.modeSelected(.nagging)
        #expect(viewModel.pendingMode == .youngCrack)

        viewModel.modeApplyTapped()
        #expect(!viewModel.isModeSheetPresented)
        #expect(viewModel.mode == .youngCrack)
    }

    @Test("'X'로 닫으면 시트만 닫히고 모드는 그대로다")
    func dismissKeepsMode() {
        let viewModel = makeViewModel(selectedUserId: Constants.friendUserId)

        viewModel.modeTapped()
        viewModel.modeSheetDismissed()

        #expect(!viewModel.isModeSheetPresented)
        #expect(viewModel.mode == .youngCrack)
    }

    @Test("이후 버전 모드는 코멘트 후보가 없어 이모지를 눌러도 로그가 늘지 않는다")
    func unavailableModeHasNoComments() {
        #expect(ReactionMode.oldCrack.comments(for: .drool, serverContents: []).isEmpty)
        #expect(ReactionMode.nagging.comments(for: .thinking, serverContents: []).isEmpty)
        #expect(!ReactionMode.youngCrack.comments(for: .money, serverContents: []).isEmpty)
    }

    @Test("남의 사진 신고를 누르면 신고 대상이 세팅되고, 완료 시 해제된다")
    func reportTargetLifecycle() throws {
        let viewModel = makeViewModel(selectedUserId: Constants.friendUserId)
        let item = try #require(viewModel.selectedItem)

        viewModel.reportTapped(item)
        #expect(viewModel.reportTarget?.userId == Constants.friendUserId)
        #expect(viewModel.reportTarget?.photoId == Constants.friendPhotoId)
        #expect(viewModel.reportTarget?.member.isMine == false)

        viewModel.reportFinished()
        #expect(viewModel.reportTarget == nil)
    }

    @Test("사진이 없는 카드는 신고 대상으로 지정되지 않는다")
    func notUploadedPhotoIsNotReportable() throws {
        let viewModel = makeViewModel(selectedUserId: Constants.notUploadedUserId)
        let item = try #require(viewModel.selectedItem)

        viewModel.reportTapped(item)

        #expect(viewModel.reportTarget == nil)
    }

    @Test("사진 삭제에 성공하면 그 카드가 '미업로드' 상태로 되돌아가고 상위에 통지된다")
    func deleteClearsPhoto() async throws {
        var didNotifyDeletion = false
        let viewModel = makeViewModel(
            selectedUserId: Constants.myUserId,
            onPhotoDeleted: { didNotifyDeletion = true }
        )
        let item = try #require(viewModel.selectedItem)

        viewModel.deleteTapped(item)
        #expect(viewModel.deletingItem != nil)

        await viewModel.deleteConfirmed()

        #expect(viewModel.deletingItem == nil)
        #expect(viewModel.selectedItem?.hasPhoto == false)
        #expect(viewModel.selectedItem?.reactions.isEmpty == true)
        #expect(didNotifyDeletion)
    }
}
