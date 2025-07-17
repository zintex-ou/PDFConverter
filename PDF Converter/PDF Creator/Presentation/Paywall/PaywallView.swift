import SwiftUI

struct PaywallView: View {
    @StateObject var viewModel = PPaywallViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    PaywallView()
}
