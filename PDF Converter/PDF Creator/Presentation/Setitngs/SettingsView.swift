import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()
    @EnvironmentObject private var coordinator: Coordinator
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 8) {
                    if !viewModel.isSubscribed {
                        LimitedOfferBannerView()
                            .onTapGesture {
                                coordinator.presentFullScreenCover(id: PaywallView.navigationID) {
                                    PaywallView()
                                }
                            }
                    }
                    
                    ForEach(viewModel.settingsCell) { item in
                        Button {
                            item.completion()
                        } label: {
                            HStack(spacing: 8) {
                                Image(item.icon)
                                
                                Text(item.title)
                                    .foregroundStyle(.black)
                                    .font(.init(style: .semiBold, size: 16))
                                
                                Spacer()
                                
                                Image(.property1Arrow2Right)
                            }
                            .padding(.all, 16)
                            .background(.white)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 24)
                            )
                        }
                    }
                }
                .padding(.all, 16)
            }
            .background(Color(hex: "#FAFAFA"))
            .scrollIndicators(.hidden)
        }
        .alert(viewModel.alertContent.title, isPresented: $viewModel.shouldShowAlert, actions: {
            
        }, message: {
            Text(viewModel.alertContent.subTitle)
        })
    }
}

#Preview {
    SettingsView()
}
