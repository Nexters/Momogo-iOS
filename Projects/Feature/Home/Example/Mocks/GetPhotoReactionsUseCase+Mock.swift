import Foundation

import DomainInterface

/// 실제 백엔드 연동 전까지 Example 앱에서 플로우를 확인하기 위한 Mock. 프로덕션 liveValue는 unimplemented로 유지한다.
extension GetPhotoReactionsUseCase {
    static let happyPath = GetPhotoReactionsUseCase { request in
        try? await Task.sleep(for: .seconds(0.2))

        // `GetGroupDetailUseCase.happyPath`의 photoId(501/1/2)와 맞물려야 카드에 태그가 노출된다.
        // 3장의 사진마다 다른 이모지(delicious/hot/flex)로 채워 4종 중 3종을 한 화면에서 확인할 수
        // 있게 한다. HMM은 사진 없는 "철수" 카드엔 태그를 띄울 자리가 없어 이 mock으로는 노출 안 됨.
        let reactions: [PhotoReaction] = switch request.photoId {
        case 501:
            [
                PhotoReaction(
                    reactionId: 1,
                    userId: 2,
                    nickname: "길동",
                    emoji: .delicious,
                    comment: "길게 쓴 코멘트는 이렇게 잘려요",
                    createdAt: "2026-08-08T14:30:00.123456",
                    isMine: false
                )
            ]
        case 1:
            [
                PhotoReaction(
                    reactionId: 2,
                    userId: 1,
                    nickname: "나",
                    emoji: .hot,
                    comment: "매워보여",
                    createdAt: "2026-08-08T14:31:00.123456",
                    isMine: true
                )
            ]
        case 2:
            [
                PhotoReaction(
                    reactionId: 3,
                    userId: 4,
                    nickname: "철수",
                    emoji: .flex,
                    comment: "완전 힙해",
                    createdAt: "2026-08-08T14:32:00.123456",
                    isMine: false
                )
            ]
        default:
            []
        }

        return GetPhotoReactionsResponse(photoId: request.photoId, groupId: request.groupId, reactions: reactions)
    }
}
