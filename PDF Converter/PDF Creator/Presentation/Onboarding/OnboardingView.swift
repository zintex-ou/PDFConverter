import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel = OnboardingViewModel()
    @EnvironmentObject private var coordinator: Coordinator
    @AppStorage(Constants.isOnboardingCompleted) var isOnboardingCompleted: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            let page = viewModel.currentPage
            
            Image(page.image)
                .resizable()
                .ignoresSafeArea()
                .overlay(alignment: .topTrailing) {
                    if viewModel.crossVisibleButton {
                        Button {
                            finishedOnboarding()
                        } label: {
                            Image(.property1Cross)
                                .renderingMode(.template)
                                .foregroundStyle(Color(hex: "#686868"))
                                .padding(.trailing, 16)
                        }
                        .opacity(viewModel.getCrossButtonOpacity())
                    }
                }
            
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
                    
                    Capsule()
                        .fill(Color(hex: "#D53131").opacity(0.3))
                        .frame(width: 6, height: 6)
                }
                .padding(.top, 16)
                
                Button(viewModel.getContinueButtonText(), action: {
                    withAnimation {
                        viewModel.tapOnContinue {
                            finishedOnboarding()
                        }
                    }
                })
                .scaleAnimation()
                .buttonStyle(.main)
                .padding(.top, 16)
                
                HStack {
                    Text("By continuing, you agree to")
                    
                    Spacer()
                    
                    Button {
                        viewModel.tapOnPrivacyButton()
                    } label: {
                        Text("Policy")
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.tapOnTermsButton()
                    } label: {
                        Text("Terms")
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.tapOnRestore {
                            finishedOnboarding()
                        }
                    } label: {
                        Text("Restore")
                    }
                }
                .foregroundStyle(Color(hex: "#686868"))
                .font(.init(style: .regular, size: 12))
                .padding(.top, 17)
                .opacity(viewModel.shouldShowPrivacyView() ? 1 : 0)
            }
            .padding(.horizontal, 16)
            .background(.white)
            .multilineTextAlignment(.center)
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .alert(viewModel.alertContent.title, isPresented: $viewModel.shouldShowAlert, actions: {
            
        }, message: {
            Text(viewModel.alertContent.subTitle)
        })
        .alert(
            viewModel.alertContent.title,
            isPresented: $viewModel.shouldShowTryAgainAlert)
        {
            Button("Cancel", role: .cancel) {}
            
            Button {
                viewModel.makePurchase {
                    finishedOnboarding()
                }
            } label: {
                Text("Try again")
            }
            
        } message: {
            Text(viewModel.alertContent.subTitle)
        }
        .animation(.default, value: viewModel.isLoading)
    }
    
    private func finishedOnboarding() {
        isOnboardingCompleted = true
        coordinator.pushTo(id: TabBarView.navigationID) {
            TabBarView()
        }
    }
}

#Preview {
    OnboardingView()
}
