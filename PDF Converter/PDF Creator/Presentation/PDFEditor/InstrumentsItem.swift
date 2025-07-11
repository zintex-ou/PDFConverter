import SwiftUI

struct InstrumentsItem: Identifiable {
    let id = UUID()
    let icon: ImageResource
    let title: LocalizedStringKey
    let comletion: () -> Void
}
