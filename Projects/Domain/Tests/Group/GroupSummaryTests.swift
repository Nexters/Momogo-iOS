import Testing

import DomainInterface

struct GroupSummaryTests {
    private func group(latestUploadAt: String?) -> GroupSummary {
        GroupSummary(
            groupId: 10,
            groupName: "우리 가족",
            totalMemberCount: 4,
            todayPhotoUploaderCount: 2,
            latestUploadAt: latestUploadAt
        )
    }

    @Test("활성 사진이 없으면(latestUploadAt이 nil) 방문 기록과 무관하게 New가 아니다")
    func hasNewPhoto_noActivePhoto_isFalse() {
        let sut = group(latestUploadAt: nil)

        #expect(sut.hasNewPhoto(lastSeenUploadAt: nil) == false)
        #expect(sut.hasNewPhoto(lastSeenUploadAt: "2026-08-01T00:00:00.000000") == false)
    }

    @Test("활성 사진은 있는데 방문 기록이 없으면(한 번도 안 본 그룹) New다")
    func hasNewPhoto_neverVisited_isTrue() {
        let sut = group(latestUploadAt: "2026-08-10T14:30:00.123456")

        #expect(sut.hasNewPhoto(lastSeenUploadAt: nil) == true)
    }

    @Test("최신 업로드 시각이 마지막으로 본 스냅샷보다 미래면 New다")
    func hasNewPhoto_uploadAfterLastSeen_isTrue() {
        let sut = group(latestUploadAt: "2026-08-10T14:30:00.123456")

        #expect(sut.hasNewPhoto(lastSeenUploadAt: "2026-08-09T00:00:00.000000") == true)
    }

    @Test("마지막으로 본 스냅샷과 최신 업로드 시각이 같으면 New가 아니다")
    func hasNewPhoto_sameAsLastSeen_isFalse() {
        let timestamp = "2026-08-10T14:30:00.123456"
        let sut = group(latestUploadAt: timestamp)

        #expect(sut.hasNewPhoto(lastSeenUploadAt: timestamp) == false)
    }

    @Test("최신 업로드 시각이 마지막으로 본 스냅샷보다 과거면 New가 아니다")
    func hasNewPhoto_uploadBeforeLastSeen_isFalse() {
        let sut = group(latestUploadAt: "2026-08-01T00:00:00.000000")

        #expect(sut.hasNewPhoto(lastSeenUploadAt: "2026-08-10T14:30:00.123456") == false)
    }
}
