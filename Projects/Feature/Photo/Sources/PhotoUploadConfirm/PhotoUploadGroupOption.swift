import Foundation

/// 업로드 확인 화면에서 선택 대상이 되는 그룹 하나의 정보.
/// 멤버 이름은 카드에 가나다순으로 노출돼야 하므로 초기화 시점에 정렬해 보관한다.
public struct PhotoUploadGroupOption: Identifiable, Equatable, Sendable {
    public let id: Int
    public let groupName: String
    public let memberNames: [String]

    public init(id: Int, groupName: String, memberNames: [String]) {
        self.id = id
        self.groupName = groupName
        self.memberNames = memberNames.sorted { $0.localizedCompare($1) == .orderedAscending }
    }

    var memberNamesText: String {
        memberNames.joined(separator: ", ")
    }
}
