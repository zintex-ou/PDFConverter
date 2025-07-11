import SwiftUI

struct SettingsItem: Identifiable {
    let id = UUID()
    let icon: ImageResource
    let title: LocalizedStringKey
    let completion: () -> Void
}
