import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let image: ImageResource
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
}
