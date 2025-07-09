import SwiftUI

struct TabBarView: View {
    @StateObject var viewModel = TabBarViewModel()
    
    var body: some View {
        VStack(spacing: .zero) {
            HStack {
                Text("PDF Creator")
                    .foregroundStyle(.black)
                    .font(.init(style: .semiBold, size: 24))
                
                Spacer()
                
                Button {
                    
                } label: {
                    HStack(spacing: 4) {
                        Image(.illustartion)
                        
                        Text("PRO")
                            .foregroundStyle(.white)
                            .font(.init(style: .semiBold, size: 16))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12.5)
                    .background(Color(hex: "#D53131"))
                    .clipShape(Capsule())
                }
                
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            
            TabView(selection: $viewModel.selectedTab) {
                HomeView()
                    .tag(TabBarItem.home)
                
                SettingsView()
                    .tag(TabBarItem.settings)
            }
            
            Divider()
            
            HStack {
                ForEach(viewModel.tabBarPages, id: \.tab) { model in
                    let isSelected = viewModel.selectedTab == model.tab
                    
                    Spacer()
                    
                    Button {
                        viewModel.select(tab: model.tab)
                    } label: {
                        VStack(spacing: 4) {
                            if model.tab == .scan {
                                Circle()
                                    .fill(Color(hex: "#D53131"))
                                    .frame(width: 44, height: 44)
                                    .overlay {
                                        Image(model.defaultIcon)
                                            .renderingMode(.template)
                                            .foregroundStyle(.white)
                                    }
                            } else {
                                Image(isSelected ? model.selectedIcon : model.defaultIcon)
                                    .renderingMode(.template)
                                    .foregroundStyle(isSelected ? Color(hex: "#D53131") : Color(hex: "#686868"))
                            }
                            
                            if let title = model.title {
                                Text(title)
                                    .font(.init(style: .regular, size: 12))
                                    .foregroundStyle(isSelected ? Color(hex: "#D53131") : Color(hex: "#686868"))
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding(.vertical, 16)
        }
        .confirmationDialog(
            "",
            isPresented: $viewModel.shouldShowScan,
            titleVisibility: .hidden
        ) {
            Button("Camera") {
                
            }
            
            Button("Gallery") {
                
            }
            
            Button("Files") {
                
            }
        }
    }
}

#Preview {
    TabBarView()
}
