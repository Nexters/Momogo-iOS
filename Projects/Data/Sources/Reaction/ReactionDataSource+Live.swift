import Foundation

import Dependencies

extension ReactionDataSource: DependencyKey {
    public static var liveValue: ReactionDataSource {
        @Dependency(\.networkClient) var networkClient

        return ReactionDataSource(
            add: { groupId, photoId, request in
                _ = try await networkClient
                    .request(ReactionTargetType.add(groupId: groupId, photoId: photoId, request: request))
            },
            list: { groupId, photoId in
                try await networkClient
                    .requestDecodable(ReactionTargetType.list(groupId: groupId, photoId: photoId))
            }
        )
    }

    public static let testValue = ReactionDataSource(
        add: unimplemented("\(Self.self).add"),
        list: unimplemented("\(Self.self).list")
    )
}
