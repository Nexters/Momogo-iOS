import Foundation

import Dependencies

public struct UserDataSource: Sendable {
    public var register: @Sendable (RegisterRequestDTO) async throws -> AuthSessionResponseDTO
    public var update: @Sendable (UpdateUserRequestDTO) async throws -> UpdateUserResponseDTO
    public var delete: @Sendable () async throws -> Void

    public init(
        register: @escaping @Sendable (RegisterRequestDTO) async throws -> AuthSessionResponseDTO,
        update: @escaping @Sendable (UpdateUserRequestDTO) async throws -> UpdateUserResponseDTO,
        delete: @escaping @Sendable () async throws -> Void
    ) {
        self.register = register
        self.update = update
        self.delete = delete
    }
}

public extension DependencyValues {
    var userDataSource: UserDataSource {
        get { self[UserDataSource.self] }
        set { self[UserDataSource.self] = newValue }
    }
}
