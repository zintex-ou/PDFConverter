import SwiftUI

struct InstrumentsItem: Identifiable {
    let id = UUID()
    let type: InstrumentsType
    let icon: ImageResource
    let title: LocalizedStringKey
    let comletion: () -> Void
}
