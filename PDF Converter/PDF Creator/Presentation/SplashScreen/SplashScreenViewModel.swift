import UIKit

final class SplashScreenViewModel: ObservableObject {
    private let remoteConfigManager: RemoteConfigManager = .shared

    func fetchConfig() async throws {
        try await remoteConfigManager.startFetching()
    }
    
    func changeViewControllres(count: Int) {
        UINavigationController.changeViewControllersCount(count)
    }
}
