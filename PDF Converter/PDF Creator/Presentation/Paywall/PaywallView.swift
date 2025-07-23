import SwiftUI

struct PaywallView: View {
    @StateObject var viewModel = PaywallViewModel()
    @EnvironmentObject private var coordinator: Coordinator
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(.bgPaywall)
                .resizable()
                .ignoresSafeArea()
                .overlay(alignment: .topTrailing) {
                    if viewModel.crossVisibleButton {
                        Button {
                            coordinator.dismissFullScreenCover()
                        } label: {
                            Image(.property1Cross)
                                .renderingMode(.template)
                                .foregroundStyle(Color(hex: "#686868"))
                                .padding(.trailing, 18)
                        }
                        .opacity(viewModel.getCrossButtonOpacity())
                    }
                }
            
            VStack(spacing: .zero) {
                VStack(spacing: 8) {
                    Text("Full access to all features")
                        .foregroundStyle(.black)
                        .font(.init(style: .semiBold, size: 24))
                    
                    Text(viewModel.subtitle)
                        .foregroundStyle(Color(hex: "#686868"))
                        .font(.init(style: .regular, size: 16))
                }
                .padding(.top, 8)
                .animation(.default, value: viewModel.subtitle)
                .transition(.move(edge: .top))
                
                VStack(spacing: 8) {
                    ForEach(viewModel.products, id: \.id) { product in
                        Button {
                            viewModel.tapOnCell(product)
                        } label: {
                            productCell(product)
                        }
                    }
                }
                .padding(.top, 36)
                
                Button(viewModel.getButtonTitle(), action: {
                    viewModel.makePurchase {
                        coordinator.dismissFullScreenCover()
                    }
                })
                .buttonStyle(.main)
                .minimumScaleFactor(0.7)
                .padding(.top, 16)
                
                HStack {
                    Text("By continuing, you agree to:")
                    
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
                            coordinator.dismissFullScreenCover()
                        }
                    } label: {
                        Text("Restore")
                    }
                }
                .font(.init(style: .regular, size: 12))
                .foregroundStyle(Color(hex: "#686868"))
                .padding(.top, 16)
            }
            .padding(.horizontal, 16)
            .background(.white)
            .multilineTextAlignment(.center)
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .animation(.default, value: viewModel.products)
        .animation(.default, value: viewModel.selectedProduct)
        .onAppear(perform: {
            viewModel.shouldShowCrossButton()
            viewModel.fetchProduct()
        })
        .alert(
            viewModel.alertContent.title,
            isPresented: $viewModel.shouldShowAlert) { } message: {
                Text(viewModel.alertContent.subTitle)
            }
            .alert(
                viewModel.alertContent.title,
                isPresented: $viewModel.shouldShowTryAgainAlert)
        {
            Button("Cancel", role: .cancel) {}
            
            Button {
                viewModel.makePurchase {
                    coordinator.dismissFullScreenCover()
                }
            } label: {
                Text("Try again")
            }
            
        } message: {
            Text(viewModel.alertContent.subTitle)
        }
    }
    
    private func productCell(_ product: ProductModel) -> some View {
        ZStack(alignment: .topTrailing) {
            let isSelected = viewModel.selectedProduct == product
            
            HStack(spacing: 8) {
                Circle()
                    .fill(.white)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .inset(by: 0.5)
                            .stroke(isSelected ? .black : Color(hex: "#686868"), lineWidth: 1)
                    )
                    .overlay {
                        Circle()
                            .fill(.black)
                            .frame(width: 16, height: 16)
                            .opacity(isSelected ? 1 : 0)
                    }
                
                Text(product.title)
                    .font(.init(style: .semiBold, size: 16))
                
                Spacer()
                
                Text("\(product.price)/\(product.description)")
                    .font(.init(style: .regular, size: 16))
            }
            .foregroundStyle(isSelected ? .black : Color(hex: "#686868"))
            .padding(.vertical, 18)
            .padding(.horizontal, 16)
            .background(isSelected ? .white : Color(hex: "#EFEFEF"))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .inset(by: 0.5)
                    .stroke(.black, lineWidth: 1)
                    .opacity(isSelected ? 1 : 0)
            )
            
            if let badge = product.badge {
                Text(badge)
                    .font(.init(style: .regular, size: 12))
                    .foregroundStyle(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color(hex: "#D53131"))
                    .clipShape(Capsule())
                    .offset(x: -16, y: -11)
            }
        }
    }
}

#Preview {
    PaywallView()
}
