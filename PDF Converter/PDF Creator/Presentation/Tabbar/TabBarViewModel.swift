import Foundation
import PhotosUI
import SwiftUI
import Combine

@MainActor
final class TabBarViewModel: ObservableObject {
    @Published var selectedTab: TabBarItem = .home
    @Published var shouldShowScan: Bool = false
    @Published var shouldShowPhotoPicker: Bool = false
    @Published var shouldShowDocumentPicker: Bool = false
    @Published var photoItems: [PhotosPickerItem] = []
    @Published var shouldShowPreviewController: Bool = false
    
    private let fileManagerService: FileManagerService = .shared
    private(set) var tabBarPages: [TabbarPage] = []
    private let createPDFServcie: CreatePDFService = .shared
    private let notificationService: NotificationService = .shared
    private var cancellable: AnyCancellable?
    private(set) var selectedFileURL: URL?
    
    init() {
        self.tabBarPages = TabbarBuilder.buildPages()
        setupSubscribers()
    }
    
    func select(tab: TabBarItem) {
        if tab == .scan {
            shouldShowScan = true
        } else {
            selectedTab = tab
        }
    }
    
    func showDocumentPicker() {
        shouldShowDocumentPicker = true
    }
    
    func showPhotoPicker() {
        shouldShowPhotoPicker = true
    }
    
    func resetPhotoItems() {
        photoItems.removeAll()
    }
    
    func shouldShowPreviewController(_ url: URL) {
        selectedFileURL = url
        shouldShowPreviewController = true
    }
    
    func resetSelectedFileURL() {
        selectedFileURL = nil
    }
    
    func addToPDFDocuments(from url: URL?) {
        guard let url else { return }
        
        Task {
            do {
                if let newURL = try await fileManagerService.copyPDFToDocuments(from: url) {
                    notificationService.post(event: .createPDFURL, object: newURL)
                }
            } catch {
                
            }
        }
    }
    
    func uppdateListOfPDFs() {
        notificationService.post(event: .updatePDFList, object: nil as String?)
    }
    
    func cameraCompletion(imagesData: [Data]) {
        Task {
            do {
                if let url = try await self.convert(imagesData: imagesData) {
                    self.notificationService.post(event: .createPDFURL, object: url)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension TabBarViewModel {
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
    
    private func convert(imagesData: [Data]) async throws -> URL? {
        let url = try await createPDFServcie.createPDFData(
            from: imagesData,
            displayScale: 1,
            in: FileManagerService.shared.getPDFDirectory()
        )
        return url
        
    }
    
    private func setupSubscribers() {
        cancellable = $photoItems
            .dropFirst()
            .removeDuplicates()
            .sink(receiveValue: { [weak self] photoItems in
                guard !photoItems.isEmpty,
                      let self else { return }
                Task {
                    do {
                        defer {
                            self.resetPhotoItems()
                        }
                        
                        let imagesData = try await self.convertPhotosPickerItemToData()
                        if let url = try await self.convert(imagesData: imagesData) {
                            self.notificationService.post(event: .createPDFURL, object: url)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            })
    }
}
