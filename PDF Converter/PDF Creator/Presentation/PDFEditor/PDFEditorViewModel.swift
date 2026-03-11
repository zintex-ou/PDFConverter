import UIKit
import SwiftUI
import PhotosUI
import Combine

@MainActor
final class PDFEditorViewModel: ObservableObject {
    enum ExtractTextState: Equatable {
        case idle
        case loading
        case success(String)
        case empty
        case failed
    }
    
    @Published var currentPage: Int = 0
    @Published var shouldShowConfirmationDialog: Bool = false
    @Published var shouldShowPhotoPicker: Bool = false
    @Published var shouldShowDocumentPicker: Bool = false
    @Published var photoItems: [PhotosPickerItem] = []
    @Published var pdfMetaData: PDFMetadata
    @Published var extractTextState: ExtractTextState = .idle
    @Published var shouldSHowCopiedAlert: Bool = false
    
    private(set) var instruments: [InstrumentsItem] = []
    private let createPDFServcie: PDFService = .shared
    private let fileManagerService: FileManagerService = .shared
    private let notificationService: NotificationService = .shared
    private let defaultMetaData: PDFMetadata
    private var cancellable: AnyCancellable?
    private var extractTextTask: Task<Void, Never>?
    
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
                notificationService.post(event: .updatePDFList, object: nil as String?)
                completion()
            } catch {
                
            }
        }
    }
    
    func addPage() {
        shouldShowConfirmationDialog = true
    }
    
    func reorderPage() {
        
    }
    
    func share() {
        UIApplication.shared.sharePDF(url: pdfMetaData.url)
    }
    
    func extractTextPage() {
        
    }
    
    func showPhotoPicker() {
        shouldShowPhotoPicker = true
    }
    
    func showDocumentPicker() {
        shouldShowDocumentPicker = true
    }
    
    func cameraCompletion(imagesData: [Data]) {
        guard !imagesData.isEmpty else { return }
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                if let metaData = try await self.mergePDFs(imagesData: imagesData) {
                    self.pdfMetaData = metaData
                    self.currentPage = 0
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func mergePDFs(imagesData: [Data]) async throws -> PDFMetadata? {
        guard let temporaryPDFURLFromImage = try await convertToPDF(from: imagesData) else {
            return nil
        }
        
        guard let mergedURL = try await createPDFServcie.mergePDFs(
            basePDFURL: pdfMetaData.url,
            additionalPDFURL: temporaryPDFURLFromImage,
            destinationURL: fileManagerService.getTemporaryDirectory()
        ) else {
            return nil
        }
        
        let newModel = try await PDFMetadataService.fetchMetadata(from: mergedURL)
        return newModel
    }
    
    func rearrangePages(newOrder: [Int]) {
        Task {
            do {
                if let url = try await createPDFServcie.rearrangePages(
                    from: pdfMetaData.url,
                    newOrder: newOrder,
                    to: fileManagerService.getTemporaryDirectory()
                ) {
                    let newModel = try await PDFMetadataService.fetchMetadata(from: url)
                    self.pdfMetaData = newModel
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func extractText() {
        extractTextTask?.cancel()
        extractTextState = .loading
        
        let pageIndex = currentPage
        
        extractTextTask = Task { [weak self] in
            guard let self else { return }
            do {
                let text = try await createPDFServcie.extractText(
                    from: pdfMetaData.url,
                    pageIndex: pageIndex
                )
                if Task.isCancelled { return }
                guard self.currentPage == pageIndex else { return }
                
                if let text, !text.isEmpty {
                    self.extractTextState = .success(text)
                } else {
                    self.extractTextState = .empty
                }
            } catch {
                if Task.isCancelled { return }
                guard self.currentPage == pageIndex else { return }
                print(error.localizedDescription)
                self.extractTextState = .failed
            }
        }
    }
    
    func coppyTextToPasteboard() {
        guard case let .success(text) = extractTextState else { return }
        shouldSHowCopiedAlert = true
        UIPasteboard.general.string = text
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.shouldSHowCopiedAlert = false
        }
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
                        let data = try await self.convertPhotosPickerItemToData()
                        if let metaData = try await self.mergePDFs(imagesData: data) {
                            self.pdfMetaData = metaData
                        }
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
    
    private func convertToPDF(from imageData: [Data]) async throws -> URL? {
        defer {
            resetPhotoItems()
        }
        
        let newTemproaryURL = try await createPDFServcie.createPDFData(
            from: imageData,
            displayScale: 1,
            in: fileManagerService.getTemporaryDirectory()
        )
        
        return newTemproaryURL
    }
}
