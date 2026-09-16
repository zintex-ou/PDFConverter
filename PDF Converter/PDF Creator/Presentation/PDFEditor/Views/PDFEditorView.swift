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
        .overlay {
            if viewModel.isProcessing {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.4)
                    }
            }
        }
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
        .confirmationDialog(
            "Tools",
            isPresented: $viewModel.shouldShowToolsMenu,
            titleVisibility: .visible
        ) {
            Button("Apply Filter") {
                viewModel.openFilterMenu()
            }
            
            Button("Compress") {
                viewModel.openCompressMenu()
            }
            
            Button("Add Watermark") {
                viewModel.openWatermarkPrompt()
            }
            
            Button("Split PDF") {
                viewModel.openSplitPicker()
            }
        }
        .confirmationDialog(
            "Apply Filter",
            isPresented: $viewModel.shouldShowFilterMenu,
            titleVisibility: .visible
        ) {
            ForEach(PDFFilterOption.allCases, id: \.self) { option in
                Button(option.title) {
                    viewModel.applyFilter(option)
                }
            }
        }
        .confirmationDialog(
            "Compress",
            isPresented: $viewModel.shouldShowCompressMenu,
            titleVisibility: .visible
        ) {
            ForEach(PDFCompressionLevel.allCases, id: \.self) { level in
                Button(level.title) {
                    viewModel.compress(level)
                }
            }
        }
        .alert("Add Watermark", isPresented: $viewModel.shouldShowWatermarkAlert) {
            TextField("Watermark text", text: $viewModel.watermarkText)
            
            Button("Cancel", role: .cancel) {}
            
            Button("Add") {
                viewModel.applyWatermark()
            }
        }
        .onChange(of: viewModel.shouldPushSplitPicker) { shouldPush in
            guard shouldPush else { return }
            viewModel.shouldPushSplitPicker = false
            coordinator.pushTo(id: SplitPDFView.navigationID) {
                SplitPDFView(viewModel: viewModel) { indices in
                    viewModel.splitPDF(indices: indices)
                }
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
                    .frame(width: 62, height: 42)
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
