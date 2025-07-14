import UIKit
import SwiftUI
import PhotosUI
import Combine

@MainActor
final class PDFEditorViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var shouldShowConfirmationDialog: Bool = false
    @Published var shouldShowPhotoPicker: Bool = false
    @Published var shouldShowDocumentPicker: Bool = false
    @Published var photoItems: [PhotosPickerItem] = []
    @Published var pdfMetaData: PDFMetadata
    
    private(set) var instruments: [InstrumentsItem] = []
    private let createPDFServcie: CreatePDFService = .shared
    private let fileManagerService: FileManagerService = .shared
    private let notificationService: NotificationService = .shared
    private let defaultMetaData: PDFMetadata
    private var cancellable: AnyCancellable?
    
    init(pdfMetaData: PDFMetadata) {
        self.pdfMetaData = pdfMetaData
        self.defaultMetaData = pdfMetaData
        self.instruments = InstrumentsBuilder.build(viewModel: self)
        setupSubscribers()
    }
    
    func tapOnSave(completion: @escaping () -> Void) {
        Task {
            do {
                try await fileManagerService.copyPDFToDocuments(from: pdfMetaData.url)
                try await fileManagerService.deletePDFDocument(at: defaultMetaData.url)
                notificationService.post(event: .updatePDFList, object: nil as String?)
                completion()
            } catch {
                
            }
        }
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
        
    }
}

extension PDFEditorViewModel {
    private func setupSubscribers() {
        cancellable = $photoItems
            .dropFirst()
            .removeDuplicates()
            .sink(receiveValue: { [weak self] photoItems in
                guard !photoItems.isEmpty, let self else { return }
                Task {
                    do {
                        guard let temporyPDFURLFromImage = try await self.convertPhotosToPDF() else { return }
                        
                        print(temporyPDFURLFromImage)

                        guard let pdfAfertMergeURL = try await self.createPDFServcie.mergePDFs(
                            basePDFURL: self.pdfMetaData.url,
                            additionalPDFURL: temporyPDFURLFromImage,
                            directory: self.fileManagerService.getTemporaryDirectory()
                        ) else { return }
                        
                        print("NewPDFURL: \(pdfAfertMergeURL)")
                        
                        let newModel = try await PDFMetadataService.fetchMetadata(from: pdfAfertMergeURL)
                        
                        self.pdfMetaData = newModel
                    } catch {
                        print(error.localizedDescription)
                    }
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
    
    private func convertPhotosToPDF() async throws -> URL? {
        defer {
            resetPhotoItems()
        }

        let data = try await convertPhotosPickerItemToData()
        
        let newTemproaryURL = try await createPDFServcie.createPDFData(
            from: data,
            displayScale: 1,
            in: fileManagerService.getTemporaryDirectory()
        )
        
        return newTemproaryURL
    }
}
