import Foundation
import SwiftUI

final class OnboardingViewModel: ObservableObject {
    @Published var pages: [OnboardingPage] = []
    @Published var currentIndex: Int = 0
    @Published var crossVisibleButton: Bool = false
    
    private let remoteConfigManager: RemoteConfigManager = .shared
    
    var currentPage: OnboardingPage {
        pages[currentIndex]
    }
    
    init() {
        self.pages = OnboardingBuilder.buildPages()
    }
    
    func tapOnContinue(onboardingCompletion: @escaping () -> Void) {
        if currentIndex < pages.count - 1 {
            currentIndex += 1
        } else {
            onboardingCompletion()
        }
    }
    
    func getCrossButtonOpacity() -> Double {
        return remoteConfigManager.config.paywallConfig.opacityCloseButton
    }
    
    func shouldShowCrossButton() {
        if currentIndex == pages.count - 1 {
            let second = remoteConfigManager.config.paywallConfig.closeActionDuration
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(second)) {
                self.crossVisibleButton = true
            }
        }
    }
    
    func getContinueButtonText() -> LocalizedStringKey {
        if currentIndex == pages.count - 1 {
            return "Continue"
        } else {
            return "Continue"
        }
    }
    
    func shouldShowPrivacyView() -> Bool {
        currentIndex == pages.count - 1
    }
}
