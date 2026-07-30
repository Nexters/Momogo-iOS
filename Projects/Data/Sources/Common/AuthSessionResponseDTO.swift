import Foundation

/// 회원가입(`/user/register`)과 로그인(`/auth/login`) 응답이 동일 shape이라 공용으로 사용한다.
public struct AuthSessionResponseDTO: Decodable, Sendable {
    public let userId: Int
    public let nickname: String
    public let accessToken: String
    public let refreshToken: String
}
