import Foundation

import Dependencies

import DomainInterface

extension UserRepository: @retroactive DependencyKey {
    public static var liveValue: UserRepository {
        @Dependency(\.userDataSource) var userDataSource

        return UserRepository(
            updateNickname: { nickname in
                _ = try await userDataSource.update(UpdateUserRequestDTO(nickname: nickname))
            },
            deleteAccount: {
                try await userDataSource.delete()
            }
        )
    }
}
