import SwiftUI

struct ReRangePagesView: View {
    @ObservedObject var viewModel: PDFEditorViewModel
    @EnvironmentObject private var coordinator: Coordinator
    @State private var draggingItem: Int?
    @State private var pageIndices: [Int] = []
    
    private var rerangePagesCompletion: ([Int]) -> Void
    
    init(
        viewModel: PDFEditorViewModel,
        rerangePagesCompletion: @escaping ([Int]) -> Void
    ) {
        self.viewModel = viewModel
        self.rerangePagesCompletion = rerangePagesCompletion
        self._pageIndices = State(initialValue: Array(0..<viewModel.pdfMetaData.pageCount))
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            navigationView
            
            HStack(spacing: 8) {
                Image(.property1Information)
                
                Text("Press and hold on page to reorder")
                    .foregroundStyle(.black)
                    .font(.init(style: .regular, size: 16))
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            GeometryReader { outerProxy in
                let totalWidth = outerProxy.size.width - 16
                
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2),
                        spacing: 16
                    ) {
                        ForEach(pageIndices, id: \.self) { index in
                            VStack(spacing: 8) {
                                PDFPageView(
                                    url: viewModel.pdfMetaData.url,
                                    size: CGSize(
                                        width: (totalWidth - 8) / 2,
                                        height: ((totalWidth - 8) / 2) * 1.414
                                    ),
                                    pageNumber: index
                                )
                                
                                Text("\(index + 1)")
                                    .font(.init(style: .regular, size: 16))
                            }
                            .onDrag {
                                self.draggingItem = index
                                return NSItemProvider(object: String(index) as NSString)
                            }
                            .onDrop(of: [.text], delegate: DropViewDelegate(
                                current: index,
                                items: $pageIndices,
                                draggingItem: $draggingItem
                            ))
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(.horizontal, 16)
        .background(Color(hex: "#FAFAFA"))
    }
    
    var navigationView: some View {
        HStack(spacing: 12) {
            Button {
                coordinator.popToBack()
            } label: {
                Image(.property1Arrow)
            }
            
            Text(viewModel.pdfMetaData.title ?? "No name")
                .foregroundStyle(.black)
                .font(.init(style: .semiBold, size: 16))
                .lineLimit(1)
            
            Spacer()
            
            Button {
                rerangePagesCompletion(pageIndices)
                coordinator.popToBack()
            } label: {
                Text("Save")
                    .font(.init(style: .semiBold, size: 16))
                    .foregroundStyle(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color(hex: "#D53131"))
                    .clipShape(Capsule())
            }
            
        }
        .padding(.bottom, 8)
        .background(Color(hex: "#FAFAFA"))
    }
}

#Preview {
    ReRangePagesView(
        viewModel: .init(
            pdfMetaData: .init(url: URL(string: "")!, creationDate: .now, pageCount: 1)
        ), rerangePagesCompletion: {_ in}
    )
}

struct DropViewDelegate: DropDelegate {
    let current: Int
    @Binding var items: [Int]
    @Binding var draggingItem: Int?
    
    func performDrop(info: DropInfo) -> Bool {
        self.draggingItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let from = draggingItem, from != current else { return }
        
        if let fromIndex = items.firstIndex(of: from),
           let toIndex = items.firstIndex(of: current) {
            withAnimation {
                let item = items.remove(at: fromIndex)
                items.insert(item, at: toIndex)
            }
        }
    }
}
