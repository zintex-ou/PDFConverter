import SwiftUI

@MainActor
struct SplashScreenView: View {
    @AppStorage(Constants.isOnboardingCompleted) var isOnboardingCompleted: Bool = false
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject var viewModel = SplashScreenViewModel()
    
    var body: some View {
        ZStack {
            Image(.icon)
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            Task {
                try await viewModel.fetchConfig()
                
                if isOnboardingCompleted {
                    viewModel.changeViewControllres(count: 2)
                    coordinator.pushTo(id: TabBarView.navigationID) {
                        TabBarView()
                    }
                } else {
                    viewModel.changeViewControllres(count: 3)
                    coordinator.pushTo(id: OnboardingView.navigationID) {
                        OnboardingView()
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
