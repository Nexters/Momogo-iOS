import Foundation

/// 업로드 확인 화면에서 선택 대상이 되는 그룹 하나의 정보.
/// 멤버 이름은 카드에 가나다순으로 노출돼야 하므로 초기화 시점에 정렬해 보관한다.
public struct PhotoUploadGroupOption: Identifiable, Equatable, Sendable {
    public let id: Int
    public let groupName: String
    public let memberNames: [String]
    /// 오늘 이미 이 그룹에 사진을 올렸으면 false. 정책상 사진을 지우기 전까지는 같은 그룹에
    /// 다시 업로드할 수 없어, 이 그룹은 선택 대상에서 제외된다.
    public let isUploadable: Bool

    public init(id: Int, groupName: String, memberNames: [String], isUploadable: Bool = true) {
        self.id = id
        self.groupName = groupName
        self.memberNames = memberNames.sorted { $0.localizedCompare($1) == .orderedAscending }
        self.isUploadable = isUploadable
    }

    var memberNamesText: String {
        memberNames.joined(separator: ", ")
    }
}
