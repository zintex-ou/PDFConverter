import SwiftUI

struct TabbarBuilder {
    static func buildPages() -> [TabbarPage] {
        [
            TabbarPage(tab: .home, defaultIcon: .property1Home, selectedIcon: .property1HomeFill, title: "Home"),
            TabbarPage(tab: .scan ,defaultIcon: .property1Scan, selectedIcon: .property1Scan, title: nil),
            TabbarPage(tab: .settings, defaultIcon: .property1Settings, selectedIcon: .property1SettingsFill, title: "Settings")
        ]
    }
}
