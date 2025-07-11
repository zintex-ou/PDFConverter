import SwiftUI

struct PhotoThumbnail: View {
    
    @Binding var image: UIImage?
    
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else {
                Rectangle()
                    .frame(width: 60, height: 60, alignment: .center)
                    .foregroundColor(.black)
            }
        }
    }
}
