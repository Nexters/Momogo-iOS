import SwiftUI

import DesignSystem
import Kingfisher

/// `NicknameEditView`/`GroupRenameView`와 동일한 구조를 따르는 사진 신고 화면.
struct ReportPhotoView: View {
    struct Constants {
        let title = "신고하기"
        let customReasonPlaceholder = "직접 작성"
        let submitButtonTitle = "신고하기"

        let contentPadding: CGFloat = 16
        let cardSpacing: CGFloat = 12
        let cardVerticalPadding: CGFloat = 12
        let cardHorizontalPadding: CGFloat = 16
        let thumbnailSize: CGFloat = 50
        let reasonListSpacing: CGFloat = 0
        let reasonRowHeight: CGFloat = 44
        let customReasonTopPadding: CGFloat = 12
        let submitButtonBottomPadding: CGFloat = 32
    }

    private let constants = Constants()

    @Bindable private var viewModel: ReportPhotoViewModel
    @FocusState private var isCustomReasonFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(viewModel: ReportPhotoViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            DSTopNavigationBar(title: constants.title, leading: {
                DSBackButton(action: { dismiss() })
            })

            ScrollView {
                VStack(alignment: .leading, spacing: constants.cardSpacing) {
                    photoCard
                    reasonList
                }
                .padding(constants.contentPadding)
            }

            Button(constants.submitButtonTitle, action: viewModel.submitTapped)
                .buttonStyle(.momogoButton(kind: .solid, tone: .primary, size: .xl, isFullWidth: true))
                .disabled(viewModel.isLoading || !viewModel.isSubmitEnabled)
                .padding(.horizontal, constants.contentPadding)
                .padding(.bottom, constants.submitButtonBottomPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .bottom)
        .background(DesignSystem.Color.gray900.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .momogoLoadingOverlay(isPresented: viewModel.isLoading)
        // 로딩 오버레이가 화면을 덮어 탭은 막지만, 인터랙티브 스와이프 백 제스처는 별개로 계속 동작하므로 같이 막는다.
        .navigationBarBackButtonHidden(viewModel.isLoading)
    }

    private var photoCard: some View {
        HStack(spacing: constants.cardSpacing) {
            thumbnail
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.photoTitle)
                    .momogoTypography(.mdSemistrong)
                    .foregroundStyle(DesignSystem.Color.gray50)
                Text(viewModel.dateText)
                    .momogoTypography(.smMedium)
                    .foregroundStyle(DesignSystem.Color.gray400)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, constants.cardHorizontalPadding)
        .padding(.vertical, constants.cardVerticalPadding)
        .background(DesignSystem.Color.gray800)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r16))
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let downloadUrl = viewModel.downloadUrl, let url = URL(string: downloadUrl) {
            // 캐시 키를 photoId로 고정해서(RemotePhotoSource), 그리드에서 이미 캐싱된 같은
            // photoId면 downloadUrl(presigned 서명)이 재조회로 바뀌었어도 네트워크 재요청 없이
            // 캐시에서 즉시 표시된다.
            KFImage(source: RemotePhotoSource.make(photoId: viewModel.photoId, downloadURL: url))
                .resizable()
                .placeholder { Color.clear }
                .scaledToFill()
                .frame(width: constants.thumbnailSize, height: constants.thumbnailSize)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r12))
        } else {
            RoundedRectangle(cornerRadius: DesignSystem.Radius.r12)
                .fill(DesignSystem.Color.gray700)
                .frame(width: constants.thumbnailSize, height: constants.thumbnailSize)
        }
    }

    private var reasonList: some View {
        VStack(alignment: .leading, spacing: constants.reasonListSpacing) {
            ForEach(ReportPhotoViewModel.Reason.allCases, id: \.self) { reason in
                DSRadioButton(reason.title, isSelected: isSelected(reason))
                    .frame(height: constants.reasonRowHeight, alignment: .leading)

                if reason == .custom, viewModel.selectedReason == .custom {
                    DSTextField(
                        constants.customReasonPlaceholder,
                        text: $viewModel.customReason,
                        characterLimit: ReportPhotoViewModel.customReasonCharacterLimit,
                        state: isCustomReasonFieldFocused ? .focused : .filled,
                        isFocused: $isCustomReasonFieldFocused
                    )
                    .padding(.top, constants.customReasonTopPadding)
                }
            }
        }
    }

    private func isSelected(_ reason: ReportPhotoViewModel.Reason) -> Binding<Bool> {
        Binding(
            get: { viewModel.selectedReason == reason },
            set: { isSelected in
                guard isSelected else { return }
                viewModel.selectedReason = reason
                if reason == .custom { isCustomReasonFieldFocused = true }
            }
        )
    }
}
