import Foundation

import Dependencies

extension ReactionDataSource: DependencyKey {
    public static var liveValue: ReactionDataSource {
        @Dependency(\.networkClient) var networkClient

        return ReactionDataSource(
            add: { groupId, memberId, request in
                try await networkClient
                    .requestDecodable(ReactionTargetType.add(groupId: groupId, memberId: memberId, request: request))
            },
            page: { groupId, memberId, date in
                try await networkClient
                    .requestDecodable(ReactionTargetType.page(groupId: groupId, memberId: memberId, date: date))
            }
        )
    }

    public static let testValue = ReactionDataSource(
        add: unimplemented("\(Self.self).add"),
        page: unimplemented("\(Self.self).page")
    )
}
