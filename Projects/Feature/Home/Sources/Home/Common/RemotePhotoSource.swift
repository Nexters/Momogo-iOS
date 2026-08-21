import Foundation

import Kingfisher

/// presigned URL은 요청마다 서명(X-Amz-Signature 등)이 바뀌어, URL 문자열을 그대로 Kingfisher
/// 캐시 키로 쓰면(기본 동작) 같은 사진이어도 재조회할 때마다 캐시 미스가 나 매번 다시 다운로드한다.
/// photoId는 삭제(그룹 연결 해제) 전까지 내용이 바뀌지 않는 불변 리소스이고(재업로드는 항상 새
/// objectKey·새 photoId를 받는 구조), 이걸 캐시 키로 고정해도 stale 위험이 없다.
enum RemotePhotoSource {
    static func make(photoId: Int, downloadURL: URL) -> Source {
        downloadURL.convertToSource(overrideCacheKey: "photo-\(photoId)")
    }
}
