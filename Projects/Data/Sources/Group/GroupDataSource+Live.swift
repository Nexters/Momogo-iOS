import Foundation

import Dependencies

extension GroupDataSource: DependencyKey {
    public static var liveValue: GroupDataSource {
        @Dependency(\.networkClient) var networkClient

        return GroupDataSource(
            create: { request in
                try await networkClient.requestDecodable(GroupTargetType.create(request))
            },
            updateName: { groupId, request in
                try await networkClient.requestDecodable(GroupTargetType.updateName(groupId: groupId, request: request))
            }
        )
    }

    public static let testValue = GroupDataSource(
        create: unimplemented("\(Self.self).create"),
        updateName: unimplemented("\(Self.self).updateName")
    )
}
