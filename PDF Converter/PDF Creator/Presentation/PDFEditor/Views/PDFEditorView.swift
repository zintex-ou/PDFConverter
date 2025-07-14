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
                var pdfURLBinding: Binding<URL> {
                    Binding(
                        get: { self.viewModel.pdfMetaData.url },
                        set: { self.viewModel.pdfMetaData.url = $0 }
                    )
                }
                
                PDFReader(
                    currentPage: $viewModel.currentPage,
                    url: pdfURLBinding
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
                    CameraView(imageCompletion: { imagesData in
                        viewModel.cameraCompletion(imagesData: imagesData)
                    })
                }
            }
            
            Button("Gallery") {
                viewModel.showPhotoPicker()
            }
        }
        .photosPicker(
            isPresented: $viewModel.shouldShowPhotoPicker,
            selection: $viewModel.photoItems,
            matching: .images,
            photoLibrary: .shared()
        )
        .animation(.default, value: viewModel.pdfMetaData)
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
                viewModel.tapOnSave {
                    coordinator.popToBack()
                }
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
        .padding(.horizontal, 16)
        .background(Color(hex: "#FAFAFA"))
    }
    
    var bottomBarView: some View {
        HStack {
            ForEach(viewModel.instruments) { instrument in
                Spacer()
                
                Button {
                    if instrument.type == .reorder {
                        coordinator.pushTo(id: ReRangePagesView.navigationID) {
                            ReRangePagesView(viewModel: viewModel) { newOrder in
                                viewModel.rearrangePages(newOrder: newOrder)
                            }
                        }
                    } else if instrument.type == .extractText {
                        coordinator.pushTo(id: ExtractTextView.navigationID) {
                            ExtractTextView(viewModel: viewModel)
                        }
                    } else {
                        instrument.comletion()
                    }
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
