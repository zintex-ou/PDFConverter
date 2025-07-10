import SwiftUI

struct HomeView: View {
    var body: some View {
        emptyView
    }
    
    private
    var emptyView: some View {
        VStack(spacing: 8) {
            Spacer()
            
            Image(.emptyState1)
            
            VStack(spacing: .zero) {
                Text("No Files Yet")
                    .font(.init(style: .semiBold, size: 16))
                
                Text("Your created files will appear here")
                    .font(.init(style: .regular, size: 16))
            }
            .foregroundStyle(.black)
            
            Spacer()
        }
    }
}

#Preview {
    HomeView()
}
