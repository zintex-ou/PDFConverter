import SwiftUI
import PDFKit

struct PDFPageView: View {
    @State var image: UIImage? = nil
    private let url: URL
    private let size: CGSize
    private let pageNumber: Int
    
    init(
        url: URL,
        size: CGSize = CGSize(width: 64, height: 64),
        pageNumber: Int
    ) {
        self.url = url
        self.size = size
        self.pageNumber = pageNumber
    }
    
    var body: some View {
        ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 6.4))
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 6.4)
                        .fill(Color(red: 0.93, green: 0.93, blue: 0.93))
                        .frame(width: size.width, height: size.height)
                }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 6.4)
                .inset(by: 0.35)
                .stroke(Color(red: 0.93, green: 0.93, blue: 0.93), lineWidth: 0.7033)
        )
        .animation(.default, value: image)
        .onAppear(perform: {
            image = getPageThumbnail()
        })
    }
    
    
    private func getPageThumbnail() -> UIImage? {
        guard let document = PDFDocument(url: url),
              let page = document.page(at: pageNumber) else { return nil }
        
        let uiImage = page.thumbnail(of: size, for: .mediaBox)
        return uiImage
    }
}

#Preview {
    PDFPageView(url: URL(string: "")!, pageNumber: 0)
}
