import Foundation
import FirebaseRemoteConfig

final class RemoteConfigManager {
    static let shared = RemoteConfigManager()
    
    private let firebaseConfig: RemoteConfig
    private(set) var config: RemoteConfigModel
    
    private init() {
        config = .default
        firebaseConfig = RemoteConfig.remoteConfig()
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = .zero
        firebaseConfig.configSettings = settings
    }
    
    func startFetching() async throws {
        do {
            let config = try await firebaseConfig.fetchAndActivate()
            switch config {
            case .successFetchedFromRemote, .successUsingPreFetchedData:
                let jsonData = self.firebaseConfig.configValue(forKey: "RemoteConfig").dataValue
                do {
                    let decodedConfig = try JSONDecoder().decode(RemoteConfigModel.self, from: jsonData)
                    self.config = decodedConfig
                } catch {
                    print("Error decoding: \(error.localizedDescription)")
                    self.config = .default
                    return
                }
            default:
                self.config = .default
                print("Error activating")
                return
            }
        } catch let error {
            self.config = .default
            print("Error fetching: \(error.localizedDescription)")
        }
    }
}
