import Foundation
import Security

import Dependencies

import DomainInterface

/// Keychain에 게스트 providerToken을 저장한다. 없으면 새 UUID를 만들어 저장 후 반환한다.
private enum GuestTokenKeychain {
    static let service = "com.momogo.guestToken"
    static let account = "guestProviderToken"

    static func read() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(decoding: data, as: UTF8.self)
    }

    static func save(_ token: String) {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        if SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess {
            SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        } else {
            var attributes = query
            attributes[kSecValueData as String] = data
            SecItemAdd(attributes as CFDictionary, nil)
        }
    }

    static func delete() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
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
