import Foundation

enum NetworkConfiguration {
    static var baseURL: URL {
        guard
            let urlString = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
            let url = URL(string: urlString)
        else {
            preconditionFailure("API_BASE_URL이 Info.plist에 설정되어 있지 않습니다.")
        }
        return url
    }
}
