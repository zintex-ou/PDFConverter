import _PhotosUI_SwiftUI

extension PhotosPickerItem {
    func loadUIImage() async throws -> UIImage? {
        guard let transferableImage = try await self.loadTransferable(type: ImageTransferable.self) else {
            return nil
        }
        
        return UIImage(data: transferableImage.imageData)
    }
    
    func loadImageData() async throws -> Data? {
        guard let transferableImage = try await self.loadTransferable(type: ImageTransferable.self) else {
            return nil
        }
        
        return transferableImage.imageData
    }
}
