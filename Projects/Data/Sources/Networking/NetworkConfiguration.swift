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

    /// API 버전 경로(`/api/v1`)가 붙지 않는 루트 URL. `/init` 계열 엔드포인트가 사용한다.
    /// baseURL이 항상 `scheme://host/api/v1/` 형태(경로 프리픽스 없이 호스트 바로 아래 API가 있음)라는 전제로 path를 통째로 제거한다.
    static var rootURL: URL {
        guard
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        else {
            preconditionFailure("API_BASE_URL을 URLComponents로 분해할 수 없습니다.")
        }
        components.path = ""
        components.query = nil
        components.fragment = nil
        guard let url = components.url else {
            preconditionFailure("API_BASE_URL에서 루트 URL을 구성할 수 없습니다.")
        }
        return url
    }

    /// 현재 앱의 마케팅 버전 (예: "1.0.0").
    static var appVersion: String {
        guard
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        else {
            preconditionFailure("CFBundleShortVersionString이 Info.plist에 설정되어 있지 않습니다.")
        }
        return version
    }
}
