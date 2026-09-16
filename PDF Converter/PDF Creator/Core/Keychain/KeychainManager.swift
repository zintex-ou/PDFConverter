import Foundation
import KeychainAccess

final class KeychainManager {
    private enum Keys: String, CodingKey {
        case userIdKey
        case purchasesExpiresAt
    }
    
    @KeychainManager.Value(
        key: Keys.userIdKey,
        encoder: .basic,
        decoder: .basic
    )
    var userIdKey: String?
    
    @KeychainManager.Value(
        key: Keys.purchasesExpiresAt,
        encoder: .basic,
        decoder: .basic
    )
    var purchasesExpiresAt: Date?

    func clear() {
        _userIdKey.clear()
        _purchasesExpiresAt.clear()
    }
}

extension KeychainManager {
    @propertyWrapper
    struct Value<Element: Codable, Key: CodingKey> {
        private let key: Key
        private let keychain: Keychain
        private let decoder: JSONDecoder
        private let encoder: JSONEncoder
        
        public var wrappedValue: Element? {
            get { readAndDecode(for: key) }
            set {
                guard let object = newValue else {
                    try? keychain.remove(key.stringValue)
                    return
                }
                encodeAndSave(object, for: key)
            }
        }
        
        //MARK: - Initialization
        init(
            key: Key,
            encoder: JSONEncoder,
            decoder: JSONDecoder
        ) {
            let service = Bundle.main.bundleIdentifier ?? "KeychainStorage"
            self.keychain = .init(
                service: service
            )
            self.key = key
            self.encoder = encoder
            self.decoder = decoder
        }
        
        //MARK: - Save/Read data
        private func readAndDecode(for key: Key) -> Element? {
            do {
                guard let data = try keychain.getData(key.stringValue) else {
                    return nil
                }
                return try decoder.decode(Element.self, from: data)
            } catch {
                // Corrupted or incompatible data (e.g. after a format change)
                // shouldn't crash the app on every future launch — treat it
                // as if nothing were stored, and clear the bad entry.
                print("KeychainStorage.Value of type: \(Element.self) decode error: \(error.localizedDescription)")
                try? keychain.remove(key.stringValue)
                return nil
            }
        }
    
        private func encodeAndSave(
            _ value: Element,
            for key: Key
        ) {
            do {
                let data = try encoder.encode(value)
                try keychain.set(
                    data,
                    key: key.stringValue
                )
            } catch {
                print("KeychainStorage.Value of type: \(Element.self) encode/save error: \(error.localizedDescription)")
            }
        }
        
        func clear() {
            try? keychain.remove(key.stringValue)
        }
    }
}
