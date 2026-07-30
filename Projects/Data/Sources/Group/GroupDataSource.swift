import Foundation

import Dependencies

public struct GroupDataSource: Sendable {
    public var create: @Sendable (CreateGroupRequestDTO) async throws -> CreateGroupResponseDTO
    public var updateName: @Sendable (Int, UpdateGroupNameRequestDTO) async throws -> UpdateGroupNameResponseDTO

    public init(
        create: @escaping @Sendable (CreateGroupRequestDTO) async throws -> CreateGroupResponseDTO,
        updateName: @escaping @Sendable (Int, UpdateGroupNameRequestDTO) async throws -> UpdateGroupNameResponseDTO
    ) {
        self.create = create
        self.updateName = updateName
    }
}

public extension DependencyValues {
    var groupDataSource: GroupDataSource {
        get { self[GroupDataSource.self] }
        set { self[GroupDataSource.self] = newValue }
    }
}
