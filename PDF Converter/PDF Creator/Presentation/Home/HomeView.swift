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
        .alert("Alert Title!", isPresented: $viewModel.shouldShowRenameAlert) {
            TextField(text: $viewModel.nameToRename) {}
            
            Button("Cancel", role: .cancel) {
                
            }
            
            Button("Ok") {
                viewModel.renamePDF()
            }
        } message: {
            Text("Enter channel name")
        }
    }
    
    private
    var listView: some View {
        List(viewModel.pdfMetaData) { metaData in
            list(cell: metaData)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.white)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .clipped()
                )
                .contextMenu(menuItems: {
                    Button {
                        viewModel.tapOnRename(metaData)
                    } label: {
                        HStack {
                            Text("Rename")
                            
                            Image(.property1Edit)
                        }
                    }
                    
                    Button {
                        viewModel.print(metaData)
                    } label: {
                        HStack {
                            Text("Print")
                            
                            Image(.property1Print)
                        }
                    }
                    
                    ShareLink(
                        "Share",
                        item: metaData.url,
                        subject: Text(metaData.title ?? "No name")
                    )
                    
                    Button(role: .destructive) {
                        viewModel.remove(metaData)
                    } label: {
                        HStack {
                            Text("Delete")
                            
                            Image(.property1Delite)
                        }
                    }
                })
        }
        .scrollContentBackground(.hidden)
        .background(Color(hex: "#FAFAFA"))
        .listRowSpacing(8)
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
    }
}

#Preview {
    HomeView()
}
