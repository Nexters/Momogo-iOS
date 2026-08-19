import Foundation

import Kingfisher

/// presigned URL은 요청마다 서명(X-Amz-Signature 등)이 바뀌어, URL 문자열을 그대로 Kingfisher
/// 캐시 키로 쓰면(기본 동작) 같은 사진이어도 재조회할 때마다 캐시 미스가 나 매번 다시 다운로드한다.
/// photoId는 삭제(그룹 연결 해제) 전까지 내용이 바뀌지 않는 불변 리소스이고(재업로드는 항상 새
/// objectKey·새 photoId를 받는 구조), 이걸 캐시 키로 고정해도 stale 위험이 없다.
///
/// FeatureHome에 같은 헬퍼가 있다 — 두 모듈이 각자 필요한 순수 함수라 얕게 중복시켰다. 캐시 키
/// 규칙(`cacheKeyPrefix`)이 양쪽에서 같아야 그룹상세에서 받은 캐시를 이 화면이 재사용할 수 있으므로,
/// 규칙을 바꿀 때는 반드시 두 곳을 함께 고친다(공용 모듈로 합치는 건 후속 과제).
enum RemotePhotoSource {
    private static let cacheKeyPrefix = "photo-"

    static func make(photoId: Int, downloadURL: URL) -> Source {
        downloadURL.convertToSource(overrideCacheKey: cacheKeyPrefix + "\(photoId)")
    }
}
