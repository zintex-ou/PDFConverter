import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var pdfMetaData: [PDFMetadata] = []
    
    private let fileManagerService: FileManagerService = .shared
    private let notificationService: NotificationService = .shared
    
    init() {
        setupSubscribers()
    }
    
    func getAllURLs() async {
        do {
            if let urls = try await fileManagerService.getAllPDFDocuments() {
                var metadataArray: [PDFMetadata] = []

                try await withThrowingTaskGroup(of: PDFMetadata?.self) { group in
                    for url in urls {
                        group.addTask {
                            guard FileManager.default.fileExists(atPath: url.path) else { return nil }
                            return try await PDFMetadataService.fetchMetadata(from: url)
                        }
                    }

                    for try await metadata in group {
                        if let metadata = metadata {
                            metadataArray.append(metadata)
                        }
                    }
                }

                pdfMetaData = metadataArray
            }
        } catch {
            
        }
    }
}

extension HomeViewModel {
    private func setupSubscribers() {
        notificationService.observe(event: .createPDFURL) { (url: URL) in
            Task {
                do {
                    try await self.pdfMetaData.insert(PDFMetadataService.fetchMetadata(from: url), at: 0)
                } catch {
                    
                }
            }
        }
    }
}
