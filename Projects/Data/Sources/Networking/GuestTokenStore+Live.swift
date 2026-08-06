import Foundation

import Dependencies

import DomainInterface

/// Keychain에 게스트 providerToken을 저장한다. 없으면 새 UUID를 만들어 저장 후 반환한다.
private enum GuestTokenKeychain {
    static let service = "com.momogo.guestToken"
    static let account = "guestProviderToken"

    static func read() -> String? {
        KeychainStore.read(service: service, account: account)
    }

    static func save(_ token: String) {
        KeychainStore.save(token, service: service, account: account)
    }

    static func delete() {
        KeychainStore.delete(service: service, account: account)
    }
}

extension GuestTokenStore: DependencyKey {
    public static let liveValue = GuestTokenStore(
        fetchOrCreate: {
            if let existing = GuestTokenKeychain.read() {
                return existing
            }
            let newToken = UUID().uuidString
            GuestTokenKeychain.save(newToken)
            return newToken
        },
        clear: {
            GuestTokenKeychain.delete()
        }
    )
}
