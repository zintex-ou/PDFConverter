import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var pdfMetaData: [PDFMetadata] = []
    @Published var shouldShowRenameAlert: Bool = false
    @Published var nameToRename: String = ""
    @Published var searchText: String = ""
    @Published var isSelecting: Bool = false
    @Published var selectedIDs: Set<UUID> = []
    
    var filteredMetaData: [PDFMetadata] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return pdfMetaData
        }
        return pdfMetaData.filter {
            ($0.title ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var selectedURLsForSharing: [URL] {
        pdfMetaData.filter { selectedIDs.contains($0.id) }.map(\.url)
    }
    
    private let fileManagerService: FileManagerService = .shared
    private let notificationService: NotificationService = .shared
    private var selectedMetaData: PDFMetadata?
    private var observerTokens: [NSObjectProtocol] = []
    
    init() {
        setupSubscribers()
    }

    deinit {
        observerTokens.forEach { notificationService.stopObserving($0) }
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
    
    func tapOnRename(_ pdfMetaData: PDFMetadata) {
        self.nameToRename = pdfMetaData.title ?? ""
        self.selectedMetaData = pdfMetaData
        self.shouldShowRenameAlert = true
    }
    
    func remove(_ pdfMetaData: PDFMetadata) {
        Task {
            do {
                self.pdfMetaData.removeAll(where: { $0.id == pdfMetaData.id })
                try await fileManagerService.deletePDFDocument(at: pdfMetaData.url)
            } catch {
                
            }
        }
    }
    
    func print(_ pdfMetaData: PDFMetadata) {
        PrintService.print(from: pdfMetaData.url, with: pdfMetaData.title ?? "No Name")
    }
    
    func renamePDF() {
        Task {
            do {
                defer {
                    nameToRename = ""
                    self.selectedMetaData = nil
                }
                
                guard !nameToRename.isEmpty,
                      let selectedMetaData else { return }
                
                if let url = try await fileManagerService.renamePDFDocument(at: selectedMetaData.url, to: nameToRename),
                   let inexOfModel = self.pdfMetaData.firstIndex(where: { $0.id == selectedMetaData.id }) {
                    let newModel = try await PDFMetadataService.fetchMetadata(from: url)
                    self.pdfMetaData[inexOfModel] = newModel
                }
            } catch {
                
            }
        }
    }
    func toggleSelectMode() {
        isSelecting.toggle()
        if !isSelecting {
            selectedIDs.removeAll()
        }
    }
    
    func isSelected(_ metaData: PDFMetadata) -> Bool {
        selectedIDs.contains(metaData.id)
    }
    
    func toggleSelection(_ metaData: PDFMetadata) {
        if selectedIDs.contains(metaData.id) {
            selectedIDs.remove(metaData.id)
        } else {
            selectedIDs.insert(metaData.id)
        }
    }
    
    func deleteSelected() {
        let itemsToDelete = pdfMetaData.filter { selectedIDs.contains($0.id) }
        for item in itemsToDelete {
            remove(item)
        }
        selectedIDs.removeAll()
        isSelecting = false
    }
}

extension HomeViewModel {
    private func setupSubscribers() {
        let token1 = notificationService.observe(event: .createPDFURL) { [weak self] (url: URL) in
            Task {
                do {
                    try await self?.pdfMetaData.insert(PDFMetadataService.fetchMetadata(from: url), at: 0)
                } catch {
                    
                }
            }
        }
        
        let token2 = notificationService.observe(event: .updatePDFList) { [weak self] in
            Task {
                await self?.getAllURLs()
            }
        }

        observerTokens.append(contentsOf: [token1, token2])
    }
}
