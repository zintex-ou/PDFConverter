import Foundation

final class TabBarViewModel: ObservableObject {
    @Published var selectedTab: TabBarItem = .home
    @Published var shouldShowScan: Bool = false
    private(set) var tabBarPages: [TabbarPage] = []
    
    init() {
        self.tabBarPages = TabbarBuilder.buildPages()
    }
    
    func select(tab: TabBarItem) {
        if tab == .scan {
            shouldShowScan = true
        } else {
            selectedTab = tab
        }
    }
}
