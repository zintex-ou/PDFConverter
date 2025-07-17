import SwiftUI
import UniformTypeIdentifiers

struct TabBarView: View {
    @StateObject var viewModel = TabBarViewModel()
    @EnvironmentObject private var coordinator: Coordinator
    
    var body: some View {
        VStack(spacing: .zero) {
            HStack {
                Text("PDF Creator")
                    .foregroundStyle(.black)
                    .font(.init(style: .semiBold, size: 24))
                
                Spacer()
                
                if !viewModel.isSubscribed {
                    Button {
                        coordinator.presentFullScreenCover(id: PaywallView.navigationID) {
                            PaywallView()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(.illustartion)
                            
                            Text("PRO")
                                .foregroundStyle(.white)
                                .font(.init(style: .semiBold, size: 16))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12.5)
                        .background(Color(hex: "#D53131"))
                        .clipShape(Capsule())
                    }
                    
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .background(Color(hex: "#FAFAFA"))
            
            TabView(selection: $viewModel.selectedTab) {
                HomeView()
                    .tag(TabBarItem.home)
                
                SettingsView()
                    .tag(TabBarItem.settings)
            }
            
            Divider()
            
            HStack {
                ForEach(viewModel.tabBarPages, id: \.tab) { model in
                    let isSelected = viewModel.selectedTab == model.tab
                    
                    Spacer()
                    
                    Button {
                        viewModel.select(tab: model.tab)
                    } label: {
                        VStack(spacing: 4) {
                            if model.tab == .scan {
                                Circle()
                                    .fill(Color(hex: "#D53131"))
                                    .frame(width: 44, height: 44)
                                    .overlay {
                                        Image(model.defaultIcon)
                                            .renderingMode(.template)
                                            .foregroundStyle(.white)
                                    }
                            } else {
                                Image(isSelected ? model.selectedIcon : model.defaultIcon)
                                    .renderingMode(.template)
                                    .foregroundStyle(isSelected ? Color(hex: "#D53131") : Color(hex: "#686868"))
                            }
                            
                            if let title = model.title {
                                Text(title)
                                    .font(.init(style: .regular, size: 12))
                                    .foregroundStyle(isSelected ? Color(hex: "#D53131") : Color(hex: "#686868"))
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding(.vertical, 16)
            .background(Color(hex: "#FAFAFA"))
        }
        .confirmationDialog(
            "",
            isPresented: $viewModel.shouldShowScan,
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
            
            Button("Files") {
                viewModel.showDocumentPicker()
            }
        }
        .fileImporter(
            isPresented: $viewModel.shouldShowDocumentPicker,
            allowedContentTypes: [
                .pdf,
                .plainText,
                .init(filenameExtension: "docx")!,
                .init(filenameExtension: "xlsx")!,
                .init(filenameExtension: "pptx")!
            ]
        ) { result in
            switch result {
            case .success(let url):
                _ = url.startAccessingSecurityScopedResource()
                
                let isPDF = url.pathExtension.lowercased() == "pdf"
                
                if isPDF {
                    viewModel.addToPDFDocuments(from: url)
                } else {
                    viewModel.shouldShowPreviewController(url)
                }
            case .failure:
                break
            }
        }
        .photosPicker(
            isPresented: $viewModel.shouldShowPhotoPicker,
            selection: $viewModel.photoItems,
            matching: .images,
            photoLibrary: .shared()
        )
        .onAppear {
            viewModel.resetPhotoItems()
        }
        .sheet(
            isPresented: $viewModel.shouldShowPreviewController,
            onDismiss: {
                viewModel.uppdateListOfPDFs()
                viewModel.resetSelectedFileURL()
            },
            content: {
                if let url = viewModel.selectedFileURL {
                    PreviewController(url: url, isPresented: $viewModel.shouldShowPreviewController)
                        .ignoresSafeArea()
                        .presentationDetents([.large])
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                let alert = UIAlertController(
                                    title: "How to Convert to PDF",
                                    message: "To convert the document to PDF, tap the Share icon, select Print, then tap the Share icon again in the Print preview and choose \"Save to Files\" to export it as a PDF to the app folder \"PDF Creator\" → \"PDFDocuments\".",
                                    preferredStyle: .alert
                                )
                                alert.addAction(UIAlertAction(title: "OK", style: .default))
                                
                                UIApplication.shared.topViewController?.present(alert, animated: true)
                            }
                        }
                }
            })
    }
}

#Preview {
    TabBarView()
}
