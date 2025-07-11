import SwiftUI

extension View {
    static var navigationID: String {
        String(describing: self)
    }
}
