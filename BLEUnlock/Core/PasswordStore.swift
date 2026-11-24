import Foundation
import Security

/// Keychain storage of the login password (generic password, this device only).
struct PasswordStore {
    let service: String
    let account: String

    enum Failure: Error { case status(OSStatus), badData }

    private var base: [String: Any] {
        return [String(kSecClass): kSecClassGenericPassword,
                String(kSecAttrAccount): account,
                String(kSecAttrService): service]
    }

    func store(_ password: String) throws {
        guard !password.isEmpty, let data = password.data(using: .utf8) else { throw Failure.badData }
        delete()
        var q = base
        q[String(kSecAttrLabel)] = "BLEUnlock"
        q[String(kSecValueData)] = data
        q[String(kSecAttrAccessible)] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        let status = SecItemAdd(q as CFDictionary, nil)
        guard status == errSecSuccess else { throw Failure.status(status) }
    }

    /// nil when no password is stored; throws on other Keychain errors.
    func fetch() throws -> String? {
        var q = base
        q[String(kSecReturnData)] = kCFBooleanTrue!
        q[String(kSecMatchLimit)] = kSecMatchLimitOne
        var item: AnyObject?
        let status = SecItemCopyMatching(q as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else { throw Failure.status(status) }
        guard let data = item as? Data, let s = String(data: data, encoding: .utf8) else { throw Failure.badData }
        return s
    }

    @discardableResult
    func delete() -> Bool {
        let status = SecItemDelete(base as CFDictionary)
        return status == errSecSuccess
    }
}
