import UIKit
import SwiftUI
import PhotosUI
import Combine

final class PDFEditorViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var shouldShowConfirmationDialog: Bool = false
    @Published var shouldShowPhotoPicker: Bool = false
    @Published var shouldShowDocumentPicker: Bool = false
    @Published var photoItems: [PhotosPickerItem] = []
    
    private(set) var pdfMetaData: PDFMetadata
    private(set) var instruments: [InstrumentsItem] = []
    private var cancellable: AnyCancellable?
    
    init(pdfMetaData: PDFMetadata) {
        self.pdfMetaData = pdfMetaData
        self.instruments = InstrumentsBuilder.build(viewModel: self)
    }
    
    func addPage() {
        shouldShowConfirmationDialog = true
    }
    
    func reorder() {
        
    }
    
    func share() {
        UIApplication.shared.sharePDF(url: pdfMetaData.url)
    }
    
    func extractText() {
        
    }
    
    func showPhotoPicker() {
        shouldShowPhotoPicker = true
    }
    
    func showDocumentPicker() {
        shouldShowDocumentPicker = true
    }
    
    func addToPDFDocuments(from url: URL?) {
        guard let url else { return }

    }
}

extension PDFEditorViewModel {
    private func setupSubscribers() {
        cancellable = $photoItems
            .dropFirst()
            .removeDuplicates()
            .sink(receiveValue: { [weak self] photoItems in
                guard !photoItems.isEmpty else { return }
                Task {
                    await self?.convertPhotos()
                }
            })
    }
    
    private func resetPhotoItems() {
        photoItems.removeAll()
    }
    
    private func convertPhotosPickerItemToData() async throws -> [Data] {
        try await withThrowingTaskGroup(of: Data?.self) { group in
            for photoItem in photoItems {
                group.addTask {
                    try await photoItem.loadImageData()
                }
            }
            
            return try await group.reduce(into: [Data]()) { result, data in
                if let data = data {
                    result.append(data)
                }
            }
        }
    }
    
    private func convertPhotos() async {
        Task {
            do {
                defer {
                    resetPhotoItems()
                }
                
                let data = try await convertPhotosPickerItemToData()
                //                let url = try await createPDFServcie.createPDFData(from: data, displayScale: 1)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
