import SwiftUI

struct LimitedOfferBannerView: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(.crown)
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Limited offer")
                        .foregroundStyle(.black)
                        .font(.init(style: .semiBold, size: 16))
                    
                    Text("Get Premium and get maximum\nopportunities")
                        .foregroundStyle(.black)
                        .font(.init(style: .regular, size: 16))
                        .padding(.top, 2)
                    
                    Text("Upgrade")
                        .foregroundStyle(.white)
                        .font(.init(style: .semiBold, size: 16))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 18.5)
                        .background(Color(hex: "#D53131"))
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
            .padding(.all, 16)
        }
        .background(Color(hex: "#EFEFEF"))
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
}

#Preview {
    LimitedOfferBannerView()
}
