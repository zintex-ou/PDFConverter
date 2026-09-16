import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @EnvironmentObject private var coordinator: Coordinator
    
    var body: some View {
        VStack(spacing: .zero) {
            if !viewModel.pdfMetaData.isEmpty {
                toolbarView
            }
            
            if viewModel.pdfMetaData.isEmpty {
                emptyView
            } else {
                listView
            }
            
            if viewModel.isSelecting {
                Divider()
                selectionActionBar
            }
        }
        .task {
            await viewModel.getAllURLs()
        }
        .animation(.default, value: viewModel.pdfMetaData.count)
        .animation(.default, value: viewModel.isSelecting)
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
    var toolbarView: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)
                
                TextField("Search", text: $viewModel.searchText)
            }
            .padding(.horizontal, 12)
            .frame(height: 36)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Button {
                viewModel.toggleSelectMode()
            } label: {
                Text(viewModel.isSelecting ? "Cancel" : "Select")
                    .font(.init(style: .semiBold, size: 14))
                    .foregroundStyle(Color(hex: "#D53131"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(hex: "#FAFAFA"))
    }
    
    private
    var selectionActionBar: some View {
        HStack {
            Spacer()
            
            Button(role: .destructive) {
                viewModel.deleteSelected()
            } label: {
                VStack(spacing: 4) {
                    Image(.property1Delite)
                        .renderingMode(.template)
                        .foregroundStyle(.red)
                    
                    Text("Delete")
                        .font(.init(style: .regular, size: 12))
                        .foregroundStyle(.red)
                }
            }
            .disabled(viewModel.selectedIDs.isEmpty)
            
            Spacer()
            
            ShareLink(items: viewModel.selectedURLsForSharing) {
                VStack(spacing: 4) {
                    Image(.property1Share)
                    
                    Text("Share")
                        .font(.init(style: .regular, size: 12))
                        .foregroundStyle(.black)
                }
            }
            .disabled(viewModel.selectedIDs.isEmpty)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .background(Color(hex: "#FAFAFA"))
    }
    
    private
    var listView: some View {
        List(viewModel.filteredMetaData) { metaData in
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
                                .renderingMode(.template)
                                .foregroundStyle(.red)
                        }
                    }
                })
                .onTapGesture {
                    if viewModel.isSelecting {
                        viewModel.toggleSelection(metaData)
                    } else {
                        coordinator.pushTo(id: PDFEditorView.navigationID) {
                            PDFEditorView(pdfMetaData: metaData)
                        }
                    }
                }
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
                
                Text("Your converted files will appear here")
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
            if viewModel.isSelecting {
                Image(systemName: viewModel.isSelected(metaData) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(viewModel.isSelected(metaData) ? Color(hex: "#D53131") : .gray)
            }
            
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
