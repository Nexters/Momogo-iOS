import Foundation

/// `PhotoRepository.liveValue`에서 서버 응답을 Domain 모델로 변환할 때 발생할 수 있는 에러.
enum PhotoRepositoryError: Error {
    /// 서버가 내려준 `uploadUrl` 문자열이 유효한 URL 형식이 아닌 경우.
    case invalidUploadURL
}
