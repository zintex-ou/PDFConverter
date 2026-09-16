import SwiftUI

struct SplitPDFView: View {
    @ObservedObject var viewModel: PDFEditorViewModel
    @EnvironmentObject private var coordinator: Coordinator
    @State private var selectedIndices: Set<Int> = []
    
    private var splitCompletion: ([Int]) -> Void
    
    init(
        viewModel: PDFEditorViewModel,
        splitCompletion: @escaping ([Int]) -> Void
    ) {
        self.viewModel = viewModel
        self.splitCompletion = splitCompletion
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            navigationView
            
            HStack(spacing: 8) {
                Image(.property1Information)
                
                Text("Tap pages to include in the new PDF")
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
                        ForEach(0..<viewModel.pdfMetaData.pageCount, id: \.self) { index in
                            let isSelected = selectedIndices.contains(index)
                            
                            VStack(spacing: 8) {
                                ZStack(alignment: .topTrailing) {
                                    PDFPageView(
                                        url: viewModel.pdfMetaData.url,
                                        size: CGSize(
                                            width: (totalWidth - 8) / 2,
                                            height: ((totalWidth - 8) / 2) * 1.414
                                        ),
                                        pageNumber: index
                                    )
                                    .opacity(isSelected ? 1.0 : 0.5)
                                    
                                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(isSelected ? Color(hex: "#D53131") : .gray)
                                        .background(Circle().fill(.white))
                                        .padding(6)
                                }
                                .onTapGesture {
                                    if isSelected {
                                        selectedIndices.remove(index)
                                    } else {
                                        selectedIndices.insert(index)
                                    }
                                }
                                
                                Text("\(index + 1)")
                                    .font(.init(style: .regular, size: 16))
                            }
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
            
            Text("Split PDF")
                .foregroundStyle(.black)
                .font(.init(style: .semiBold, size: 16))
                .lineLimit(1)
            
            Spacer()
            
            Button {
                splitCompletion(Array(selectedIndices))
                coordinator.popToBack()
            } label: {
                Text("Split")
                    .font(.init(style: .semiBold, size: 16))
                    .foregroundStyle(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(selectedIndices.isEmpty ? Color.gray : Color(hex: "#D53131"))
                    .clipShape(Capsule())
            }
            .disabled(selectedIndices.isEmpty)
        }
        .padding(.bottom, 8)
        .background(Color(hex: "#FAFAFA"))
    }
}

#Preview {
    SplitPDFView(
        viewModel: .init(
            pdfMetaData: .init(url: URL(string: "")!, creationDate: .now, pageCount: 1)
        ), splitCompletion: { _ in }
    )
}
