import SwiftUI
import PhotosUI

struct ImageTransferable: Transferable {
    let imageData: Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            
            return ImageTransferable(imageData: data)
        }
    }
}
