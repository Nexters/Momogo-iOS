import Foundation

import FeaturePhoto

/// 실제 그룹 상세 API(멤버 이름 포함) 연동 전까지 Example 앱에서 화면을 확인하기 위한 Mock.
extension PhotoUploadGroupOption {
    static let mockOptions: [PhotoUploadGroupOption] = [
        PhotoUploadGroupOption(
            id: 1,
            groupName: "성민아 밥먹자",
            memberNames: ["가가", "나나", "다다", "라라", "마마", "바바", "사사", "아아", "자자"]
        ),
        PhotoUploadGroupOption(id: 2, groupName: "우리 가족", memberNames: ["엄마", "아빠"]),
        PhotoUploadGroupOption(id: 3, groupName: "예랑이 점심", memberNames: ["예랑이"])
    ]
}
