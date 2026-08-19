import Foundation

import DesignSystem
import DomainInterface

/// 이 모듈의 화면 문구·수치를 한곳에 모은다. `static`으로 두는 이유는 모델/ViewModel의 static
/// 컨텍스트(목 데이터 생성 등)에서도 같은 값을 참조해야 하기 때문이다.
private enum Constants {
    static let droolAccessibilityLabel = "침 흘리는 얼굴"
    static let hotAccessibilityLabel = "더운 얼굴"
    static let moneyAccessibilityLabel = "돈 모양의 입이 있는 얼굴"
    static let thinkingAccessibilityLabel = "생각하는 얼굴"

    static let youngCrackModeTitle = "영크크 모드"
    static let oldCrackModeTitle = "늙크크 모드"
    static let naggingModeTitle = "잔소리 모드"
    static let unavailableModeSuffix = " (이후 버전)"

    static let myLunchTitle = "나의 점심"
    static let lunchTitleSuffix = "의 점심"

    static let myEmptyMessage = "아직 받은 리액션이 없어요.\n다른 점심메이트에게 리액션하러 가볼까요?"
    static let friendEmptyMessage = "아래 이모지를 눌러 첫 리액션을 남겨주세요!\n어떤 코멘트가 나올까요?"
    static let friendNotUploadedMessage = "아직 친구가 점심을 올리지 않았어요!"

    /// 이모지별 '영크크 모드' 코멘트 후보. 서버가 내려주지 않고 클라이언트가 고정 보유하는 목록이다.
    static let droolComments = [
        "야르~",
        "대 존 맛",
        "JMT",
        "굿이여",
        "완전히 야르다",
        "비주얼 미쳤다.. 침 줄줄",
        "할렐야루",
        "실수로 너무 많이 먹었어요",
        "츄베릅",
        "얌얌 굿~",
        "위장이 기립박수 중",
        "야르지다, 야르져~",
        "메뉴 선정 감다살",
        "이 집 좀 치네"
    ]
    static let hotComments = [
        "매워보여",
        "맵짱님 멋있어요",
        "맵찔이는 포기",
        "눈물만 졸졸",
        "섹시 푸드 OH MY GOD",
        "WHO MADE THIS",
        "우유 수혈",
        "맵고수 등장",
        "혀야 미안해…",
        "혀 초비상",
        "RED RED"
    ]
    static let moneyComments = [
        "와 얼마냐",
        "Flex~",
        "역시 부자다",
        "나도 사줘",
        "로또 맞음?",
        "형님 역시는 역시네요",
        "한입만",
        "실례가 안 된다면 아이스크림 하나만 사주십시오",
        "옆자리 비었나요?",
        "냄새라도 나눠주세요",
        "자본력 무엇",
        "메뉴에서 자본력이 느껴짐;;"
    ]
    static let thinkingComments = [
        "뭘 먹은거임?",
        "이걸 왜 먹음?",
        "왜 먹는거임?",
        "분명 다이어트 한다고..",
        "이게 최선임?",
        "흠.. 이번 디쉬는 soso",
        "이것 뭐에요~???",
        "우웩",
        "돈 주고 먹은 거임?",
        "보기만 해도 입맛 퇴근",
        "돈 받고 먹겠습니다.",
        "메뉴 선정 과정이 궁금해짐"
    ]
}

/// 리액션 버튼 바에 고정 노출되는 이모지 4종(Figma `Illust_Imoji` 컴포넌트 세트와 1:1 대응).
public enum ReactionEmoji: String, CaseIterable, Identifiable, Sendable {
    case drool
    case hot
    case money
    case thinking

    public var id: String { rawValue }

    var asset: DesignSystemImages {
        switch self {
        case .drool: DesignSystemAsset.illustImojiDrool
        case .hot: DesignSystemAsset.illustImojiHot
        case .money: DesignSystemAsset.illustImojiMoney
        case .thinking: DesignSystemAsset.illustImojiThinking
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .drool: Constants.droolAccessibilityLabel
        case .hot: Constants.hotAccessibilityLabel
        case .money: Constants.moneyAccessibilityLabel
        case .thinking: Constants.thinkingAccessibilityLabel
        }
    }

    /// '영크크 모드'에서 뽑는 코멘트 후보.
    var youngCrackComments: [String] {
        switch self {
        case .drool: Constants.droolComments
        case .hot: Constants.hotComments
        case .money: Constants.moneyComments
        case .thinking: Constants.thinkingComments
        }
    }
}

/// 코멘트 톤을 결정하는 모드. 1차 버전은 '영크크 모드'만 쓸 수 있고, 나머지는 바텀시트에
/// '(이후 버전)'으로 비활성 노출된다(Figma: 반응_모드변경).
public enum ReactionMode: String, CaseIterable, Identifiable, Sendable {
    case youngCrack
    case oldCrack
    case nagging

    public var id: String { rawValue }

    /// 버튼 바에 노출되는 이름.
    var title: String {
        switch self {
        case .youngCrack: Constants.youngCrackModeTitle
        case .oldCrack: Constants.oldCrackModeTitle
        case .nagging: Constants.naggingModeTitle
        }
    }

    /// 바텀시트 항목 이름.
    var sheetTitle: String { isAvailable ? title : title + Constants.unavailableModeSuffix }

    var isAvailable: Bool { self == .youngCrack }

    /// 1차 버전은 영크크 모드만 쓸 수 있어, 나머지 모드는 후보 문구가 없다.
    func comments(for emoji: ReactionEmoji) -> [String] {
        isAvailable ? emoji.youngCrackComments : []
    }
}

/// '받은 리액션' 로그 한 줄(누가, 어떤 이모지로, 어떤 코멘트를 남겼는지).
public struct ReactionLogEntry: Identifiable, Equatable, Sendable {
    /// 내가 남긴 리액션의 표기명(Figma TagL Variant3). 서버 연동 전에는 내 닉네임을 알 수 없어
    /// 이 값을 `nickname`으로도 그대로 쓴다.
    static let myDisplayName = "나"

    public let id: UUID
    public let nickname: String
    public let isMine: Bool
    public let emoji: ReactionEmoji
    public let comment: String

    public init(
        id: UUID = UUID(),
        nickname: String,
        isMine: Bool,
        emoji: ReactionEmoji,
        comment: String
    ) {
        self.id = id
        self.nickname = nickname
        self.isMine = isMine
        self.emoji = emoji
        self.comment = comment
    }

    var displayName: String { isMine ? Self.myDisplayName : nickname }
}

/// 가로 페이저 카드 1장 = 그룹원 1명의 그날 사진과 그 사진이 받은 리액션 로그.
public struct ReactionPhotoItem: Identifiable, Equatable, Sendable {
    public var member: GroupMember
    public var reactions: [ReactionLogEntry]

    public var id: Int { member.userId }

    public init(member: GroupMember, reactions: [ReactionLogEntry] = []) {
        self.member = member
        self.reactions = reactions
    }

    var hasPhoto: Bool { member.photo != nil }

    /// 사진 좌상단 칩 문구.
    var title: String {
        member.isMine ? Constants.myLunchTitle : member.nickname + Constants.lunchTitleSuffix
    }

    /// 내 사진에는 리액션할 수 없고, 아직 올라오지 않은 사진에도 리액션할 수 없다.
    /// 이 값이 false면 Button Bar가 Opacity 30%로 비활성된다.
    var isReactable: Bool { hasPhoto && !member.isMine }

    /// 업로드가 끝난 사진에만 미트볼 메뉴(신고하기 / 점심 사진 지우기)가 뜬다.
    /// 미업로드 카드에서 배지를 숨기는 근거이기도 하다(Figma: 반응_*_미업로드).
    var showsMenu: Bool { hasPhoto }

    /// 리액션이 하나도 없을 때 노출하는 엠티뷰 안내 문구(Figma 3종).
    var emptyMessage: String {
        if member.isMine {
            Constants.myEmptyMessage
        } else if hasPhoto {
            Constants.friendEmptyMessage
        } else {
            Constants.friendNotUploadedMessage
        }
    }

    /// 신고 화면에 넘길 대상으로 변환한다. 사진이 없으면 신고 대상이 아니라 nil이다.
    func reportTarget() -> ReactionReportTarget? {
        guard let photo = member.photo else { return nil }

        return ReactionReportTarget(
            userId: member.userId,
            nickname: member.nickname,
            photoId: photo.photoId,
            downloadUrl: photo.downloadUrl
        )
    }
}

/// 신고 화면(`ReportPhotoView`)에 넘길 대상. 신고 화면 자체는 FeatureHome이 소유하므로 이 모듈은
/// "누구를 신고할지"만 들고 있는다. `navigationDestination(item:)`이 요구하는 Hashable을 만족시키려고
/// Hashable이 아닌 `GroupMember`를 그대로 쓰지 않고 얇은 값 타입으로 감쌌다.
public struct ReactionReportTarget: Identifiable, Hashable, Sendable {
    public let userId: Int
    public let nickname: String
    public let photoId: Int
    public let downloadUrl: String

    public var id: Int { userId }

    /// 신고 화면이 요구하는 도메인 모델. 남의 사진만 신고 대상이라 `isMine`은 항상 false다.
    public var member: GroupMember {
        GroupMember(
            userId: userId,
            nickname: nickname,
            isMine: false,
            photo: GroupMemberPhoto(photoId: photoId, downloadUrl: downloadUrl)
        )
    }
}
