import SwiftUI

struct PDFEditorView: View {
    @StateObject var viewModel: PDFEditorViewModel
    @EnvironmentObject private var coordinator: Coordinator
    
    init(pdfMetaData: PDFMetadata) {
        self._viewModel = StateObject(wrappedValue: PDFEditorViewModel(pdfMetaData: pdfMetaData))
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            navigationView
            
            ZStack(alignment: .topTrailing) {
                PDFReader(
                    currentPage: $viewModel.currentPage,
                    url: viewModel.pdfMetaData.url
                )
                
                Text("\(viewModel.currentPage + 1)/\(viewModel.pdfMetaData.pageCount)")
                    .font(.init(style: .regular, size: 14))
                    .padding(.trailing, 16)
            }
            
            Divider()
            
            bottomBarView
        }
        .background(Color(hex: "#FAFAFA"))
        .confirmationDialog(
            "",
            isPresented: $viewModel.shouldShowConfirmationDialog,
            titleVisibility: .hidden
        ) {
            Button("Camera") {
                coordinator.presentFullScreenCover(id: CameraView.navigationID) {
                    CameraView()
                }
            }
            
            Button("Gallery") {
                viewModel.showPhotoPicker()
            }
            
            Button("PDF File") {
                viewModel.showDocumentPicker()
            }
        }
        .photosPicker(
            isPresented: $viewModel.shouldShowPhotoPicker,
            selection: $viewModel.photoItems,
            matching: .images,
            photoLibrary: .shared()
        )
        .fileImporter(
            isPresented: $viewModel.shouldShowDocumentPicker,
            allowedContentTypes: [
                .pdf
            ]
        ) { result in
            switch result {
            case .success(let url):
                _ = url.startAccessingSecurityScopedResource()
                viewModel.addToPDFDocuments(from: url)
            case .failure:
                break
            }
        }
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
            
            Spacer()
        }
        .padding(.bottom, 8)
        .padding(.horizontal, 16)
        .background(Color(hex: "#FAFAFA"))
    }
    
    var bottomBarView: some View {
        HStack {
            ForEach(viewModel.instruments) { instrument in
                Spacer()
                
                Button {
                    instrument.comletion()
                } label: {
                    VStack(spacing: 4) {
                        Image(instrument.icon)
                        
                        Text(instrument.title)
                            .font(.init(style: .regular, size: 12))
                            .foregroundStyle(.black)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 16)
        .background(Color(hex: "#FAFAFA"))
    }
}

#Preview {
    PDFEditorView(pdfMetaData: .init(url: URL(string: "")!, creationDate: .now, pageCount: 1))
}
