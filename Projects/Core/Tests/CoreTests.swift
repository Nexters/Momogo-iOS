import XCTest
@testable import Core

final class CoreTests: XCTestCase {
    func test_방금_전이면_방금_전_문자열을_반환한다() {
        let now = Date()
        let date = now.addingTimeInterval(-10)

        XCTAssertEqual(RelativeTimeFormatter.string(from: date, to: now), "방금 전")
    }

    func test_5분_전이면_5분_전_문자열을_반환한다() {
        let now = Date()
        let date = now.addingTimeInterval(-5 * 60)

        XCTAssertEqual(RelativeTimeFormatter.string(from: date, to: now), "5분 전")
    }

    func test_3시간_전이면_3시간_전_문자열을_반환한다() {
        let now = Date()
        let date = now.addingTimeInterval(-3 * 3600)

        XCTAssertEqual(RelativeTimeFormatter.string(from: date, to: now), "3시간 전")
    }

    func test_2일_전이면_2일_전_문자열을_반환한다() {
        let now = Date()
        let date = now.addingTimeInterval(-2 * 86400)

        XCTAssertEqual(RelativeTimeFormatter.string(from: date, to: now), "2일 전")
    }
}
