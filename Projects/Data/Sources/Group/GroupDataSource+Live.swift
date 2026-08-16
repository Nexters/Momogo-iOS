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
            },
            checkInvitation: { code in
                try await networkClient.requestDecodable(GroupTargetType.checkInvitation(code: code))
            },
            join: { request in
                try await networkClient.requestDecodable(GroupTargetType.join(request))
            },
            list: {
                try await networkClient.requestDecodable(GroupTargetType.list)
            },
            detail: { groupId, date in
                try await networkClient.requestDecodable(GroupTargetType.detail(groupId: groupId, date: date))
            },
            leave: { groupId in
                _ = try await networkClient.request(GroupTargetType.leave(groupId: groupId))
            },
            reportPhoto: { groupId, photoId, request in
                _ = try await networkClient.request(
                    GroupTargetType.reportPhoto(groupId: groupId, photoId: photoId, request: request)
                )
            },
            unlinkPhoto: { groupId, photoId in
                _ = try await networkClient.request(GroupTargetType.unlinkPhoto(groupId: groupId, photoId: photoId))
            }
        )
    }

    public static let testValue = GroupDataSource(
        create: unimplemented("\(Self.self).create"),
        updateName: unimplemented("\(Self.self).updateName"),
        checkInvitation: unimplemented("\(Self.self).checkInvitation"),
        join: unimplemented("\(Self.self).join"),
        list: unimplemented("\(Self.self).list"),
        detail: unimplemented("\(Self.self).detail"),
        leave: unimplemented("\(Self.self).leave"),
        reportPhoto: unimplemented("\(Self.self).reportPhoto"),
        unlinkPhoto: unimplemented("\(Self.self).unlinkPhoto")
    )
}
