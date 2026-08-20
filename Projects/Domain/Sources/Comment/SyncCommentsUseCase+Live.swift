import Dependencies

import DomainInterface

extension SyncCommentsUseCase: DependencyKey {
    public static var liveValue: SyncCommentsUseCase {
        @Dependency(\.commentRepository) var commentRepository
        @Dependency(\.commentCatalogStore) var commentCatalogStore

        return SyncCommentsUseCase(
            execute: {
                // ① 네트워크·디코딩 실패는 여기서 throw되어 store.save에 도달하지 않는다 → 기존 캐시 무손상.
                let remote = try await commentRepository.fetchCatalog()

                // ② revision이 없거나(서버에 등록된 문구가 없음) 문구가 하나도 없으면 덮어쓰지 않는다.
                //    이 정책은 "stale > empty"를 택한 것이다 — 운영자가 문구를 의도적으로 전부 내린
                //    경우에도 클라이언트는 기존 문구를 계속 쓴다.
                guard remote.isUsable else { return }

                // ③ revision이 캐시와 같으면 쓰기를 생략한다(UserDefaults 쓰기 낭비 방지).
                guard remote.revision != commentCatalogStore.load()?.revision else { return }

                // ④ 새 revision이면 전량 교체한다.
                commentCatalogStore.save(remote)
            }
        )
    }
}
