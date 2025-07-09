import Foundation
import SwiftUI

final class OnboardingViewModel: ObservableObject {
    @Published var pages: [OnboardingPage] = []
    @Published var currentIndex: Int = 0
    
    var currentPage: OnboardingPage {
        pages[currentIndex]
    }
    
    init() {
        self.pages = OnboardingBuilder.buildPages()
    }
    
    func tapOnContinue() {
        if currentIndex < pages.count - 1 {
            currentIndex += 1
        } else {
            
        }
    }
}
