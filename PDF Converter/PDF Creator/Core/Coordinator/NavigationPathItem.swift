import SwiftUI

final class NavigationPathItem: Identifiable, Hashable {
    let id: String
    var isShown: Bool
    var destination: () -> AnyView
    
    init(id: String, isShown: Bool = false, destination: @escaping () -> AnyView) {
        self.id = id
        self.isShown = isShown
        self.destination = destination
    }
    
    static func == (lhs: NavigationPathItem, rhs: NavigationPathItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
