import UIKit

@MainActor
final class SplashScreenViewModel: ObservableObject {
    private let remoteConfigManager: RemoteConfigManager = .shared
    private let subscriptionService: SubscriptionService = .shared

    func fetchConfig() async {
        try? await remoteConfigManager.startFetching()
    }
    
    func startAdaptySubscription() async {
       await subscriptionService.start()
    }
    
    func changeViewControllres(count: Int) {
        UINavigationController.changeViewControllersCount(count)
    }
}
