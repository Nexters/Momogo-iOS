import Foundation

/// 두 날짜 사이의 간격을 "3분 전", "2시간 전"과 같은 상대 시간 문자열로 변환합니다.
public enum RelativeTimeFormatter {
    public static func string(from date: Date, to now: Date = Date()) -> String {
        let seconds = max(0, Int(now.timeIntervalSince(date)))

        switch seconds {
        case 0 ..< 60:
            return "방금 전"
        case 60 ..< 3600:
            return "\(seconds / 60)분 전"
        case 3600 ..< 86400:
            return "\(seconds / 3600)시간 전"
        case 86400 ..< 2_592_000:
            return "\(seconds / 86400)일 전"
        default:
            return "\(seconds / 2_592_000)개월 전"
        }
    }
}
