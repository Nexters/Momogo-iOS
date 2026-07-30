import Foundation

import Dependencies

extension ReactionDataSource: DependencyKey {
    public static var liveValue: ReactionDataSource {
        @Dependency(\.networkClient) var networkClient

        return ReactionDataSource(
            add: { groupId, memberId, request in
                try await networkClient
                    .requestDecodable(ReactionTargetType.add(groupId: groupId, memberId: memberId, request: request))
            }
        )
    }

    public static let testValue = ReactionDataSource(
        add: unimplemented("\(Self.self).add")
    )
}
