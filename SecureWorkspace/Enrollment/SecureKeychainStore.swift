import Foundation
import Security

/// Keychain wrapper for enrollment tokens and mail credentials.
/// All items are stored with device-only accessibility: they never
/// leave this device, never sync to iCloud, and never migrate to a
/// new device or another app's keychain.
public final class SecureKeychainStore {
    public static let shared = SecureKeychainStore()

    public enum Key: String {
        case enrollmentToken
        case mailAccount
    }

    public enum KeychainError: LocalizedError {
        case unexpectedStatus(OSStatus)

        public var errorDescription: String? {
            switch self {
            case let .unexpectedStatus(status):
                return "Keychain error (OSStatus \(status))"
            }
        }
    }

    private let service: String

    public init(service: String = "in.valuenable.secureworkspace.keychain") {
        self.service = service
    }

    // MARK: - Data

    public func setValue(_ data: Data, for key: String) throws {
        let baseQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(baseQuery as CFDictionary)

        var addQuery = baseQuery
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
    }

    public func value(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    public func removeValue(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - String conveniences

    public func setString(_ string: String, for key: String) throws {
        try setValue(Data(string.utf8), for: key)
    }

    public func string(for key: String) -> String? {
        guard let data = value(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Codable conveniences

    public func setCodable<T: Encodable>(_ value: T, for key: String) throws {
        try setValue(try JSONEncoder().encode(value), for: key)
    }

    public func codable<T: Decodable>(_ type: T.Type, for key: String) -> T? {
        guard let data = value(for: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
