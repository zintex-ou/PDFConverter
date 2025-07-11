import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
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
}

#Preview {
    SettingsView()
}
