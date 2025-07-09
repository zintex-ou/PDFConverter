import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            let page = viewModel.currentPage
            
            Image(page.image)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: .zero) {
                Text(page.title)
                    .font(.init(style: .bold, size: 20))
                    .foregroundStyle(.black)
                    .padding(.top, 8)
                
                Text(page.subtitle)
                    .font(.init(style: .regular, size: 16))
                    .foregroundStyle(Color(hex: "#686868"))
                    .padding(.top, 8)
                
                HStack(spacing: 8) {
                    ForEach(viewModel.pages, id: \.id) { item in
                        let isSelected = item.id == page.id
                        
                        Capsule()
                            .fill(isSelected ? Color(hex: "#D53131") : Color(hex: "#D53131").opacity(0.3))
                            .frame(width: isSelected ? 36 : 6, height: 6)
                    }
                }
                .padding(.top, 16)
                
                Button("Continue", action: {
                    withAnimation {
                        viewModel.tapOnContinue()
                    }
                })
                .buttonStyle(.main)
                .scaleAnimation()
                .padding(.top, 16)
            }
            .padding(.horizontal, 16)
            .background(.white)
            .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    OnboardingView()
}
