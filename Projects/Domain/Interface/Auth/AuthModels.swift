import Foundation

/// 게스트 또는 소셜 로그인에 사용하는 인증 provider.
public enum AuthProvider: String, Sendable, Codable {
    case guest = "GUEST"
}

/// 게스트 또는 소셜 provider로 회원가입할 때 사용하는 요청 모델.
public struct SignUpRequest: Sendable, Equatable {
    public let provider: AuthProvider
    public let providerToken: String
    public let nickname: String

    public init(provider: AuthProvider, providerToken: String, nickname: String) {
        self.provider = provider
        self.providerToken = providerToken
        self.nickname = nickname
    }
}

/// 회원가입 성공 시 반환되는 응답 모델.
public struct SignUpResponse: Sendable, Equatable {
    public let userId: Int
    public let nickname: String
    public let accessToken: String
    public let refreshToken: String

    public init(userId: Int, nickname: String, accessToken: String, refreshToken: String) {
        self.userId = userId
        self.nickname = nickname
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
