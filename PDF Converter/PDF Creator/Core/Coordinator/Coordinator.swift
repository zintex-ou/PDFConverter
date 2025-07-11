import SwiftUI

final class Coordinator: ObservableObject {
    @Published var path: [NavigationPathItem] = []
    @Published var fullScreenCover: FullScreenCoverItem?
    
    func pushTo(id: String, destination: @escaping () -> some View) {
        let item = NavigationPathItem(id: id) {
            AnyView(destination())
        }
        item.isShown = true
        path.append(item)
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func popTo(id: String) {
        guard let index = path.firstIndex(where: { $0.id == id }),
              !path.isEmpty, index < path.count else { return }
        path.removeLast(path.count - (index + 1))
    }
    
    func popToBack() {
        path.removeLast()
    }
    
    func resetNavPath() {
        path.removeAll()
    }
    
    func presentFullScreenCover(id: String, @ViewBuilder content: @escaping () -> some View) {
        fullScreenCover = FullScreenCoverItem(id: id, content: AnyView(content()))
    }
    
    func dismissFullScreenCover() {
        fullScreenCover = nil
    }
}
