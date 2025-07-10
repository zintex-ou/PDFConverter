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
    
    private(set) var tabBarPages: [TabbarPage] = []
    private let createPDFServcie: CreatePDFService = .shared
    private let notificationService: NotificationService = .shared
    private var cancellable: AnyCancellable?
    
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
    
    private func convertPhotos() async {
        defer {
            resetPhotoItems()
        }
        
        Task {
            do {
                let data = try await convertPhotosPickerItemToData()
                let url = try await createPDFServcie.createPDFData(from: data, displayScale: 1)
                notificationService.post(event: .createPDFURL, object: url)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
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
}
