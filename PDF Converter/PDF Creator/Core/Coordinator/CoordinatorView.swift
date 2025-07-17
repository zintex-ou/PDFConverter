import SwiftUI

@MainActor
struct CoordinatorView: View {
    @AppStorage(Constants.isOnboardingCompleted) private var isOnboardingCompleted: Bool = false
    @StateObject private var coordinator = Coordinator()
    @Environment(\.scenePhase) private var scenePhase
    
    private let remoteConfigManager: RemoteConfigManager = .shared
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            SplashScreenView()
                .navigationDestination(for: NavigationPathItem.self) { destination in
                    destination.destination()
                        .navigationBarBackButtonHidden(true)
                }
                .fullScreenCover(item: $coordinator.fullScreenCover) { item in
                    item.content
                        .navigationBarBackButtonHidden(true)
                }
                .onChange(of: scenePhase, perform: { newPhase in
//                    if newPhase == .active,
//                       isOnboardingCompleted
//                    //                       !purchaseManager.isActivityPurchases()
//                    {
//                        Task {
//                            try await fetchConfig()
//                            
//                            coordinator.presentFullScreenCover(id: PaywallView.navigationID) {
//                                PaywallView()
//                            }
//                        }
//                    }
                })
        }
        .environmentObject(coordinator)
    }
    
    private func fetchConfig() async throws {
        try await remoteConfigManager.startFetching()
    }
}
