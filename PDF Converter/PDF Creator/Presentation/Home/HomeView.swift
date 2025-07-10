import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        VStack(spacing: .zero) {
            if viewModel.pdfMetaData.isEmpty {
                emptyView
            } else {
                listView
            }
        }
        .task {
            await viewModel.getAllURLs()
        }
        .animation(.default, value: viewModel.pdfMetaData.count)
    }
    
    private
    var listView: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(viewModel.pdfMetaData) { metaData in
                    list(cell: metaData)
                }
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, 16)
        .background(Color(hex: "#FAFAFA"))
        .scrollIndicators(.hidden)
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
            .padding(.horizontal, 16)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#FAFAFA"))
    }
    
    private
    func list(cell metaData: PDFMetadata) -> some View {
        HStack(spacing: 8) {
            PDFPageView(
                url: metaData.url,
                size: .init(width: 43, height: 56),
                pageNumber: 0
            )
            
            VStack(alignment: .leading) {
                Text(metaData.title ?? "No name")
                    .font(.init(style: .bold, size: 20))
                
                HStack {
                    if let date = metaData.creationDate {
                        Text(date, style: .date)
                    }
                    
                    Spacer()
                    
                    Text("\(metaData.pageCount) pages")
                }
            }
            .lineLimit(1)
        }
        .padding(.all, 16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    HomeView()
}
