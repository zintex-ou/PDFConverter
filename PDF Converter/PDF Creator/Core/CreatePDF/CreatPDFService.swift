import Foundation
import SwiftUICore
import _PhotosUI_SwiftUI
import SwiftUI

@MainActor
final class CreatePDFService {
    static let shared = CreatePDFService()
    
    private let metaData = [
        kCGPDFContextAllowsPrinting: true
    ]
    
    private var rect: CGRect {
        CGRect(
            x: 0,
            y: 0,
            width: PageConstants.pageWidth * PageConstants.dotsPerInch,
            height: PageConstants.pageHeight * PageConstants.dotsPerInch
        )
    }
    
    private init() {}
    
    func createPDFData(from imagesData: [Data], displayScale: CGFloat) async throws -> URL? {
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = metaData as [String: Any]
        let renderer = UIGraphicsPDFRenderer(bounds: rect, format: format)
        let date = Date()
        
        let fileName = "PDF_\(date.timeIntervalSince1970).pdf"
        guard let documentsDirectory = FileManagerService.shared.getPDFDirectory() else {
            print("Failed to create documents directory")
            return nil
        }
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        try renderer.writePDF(to: fileURL) { context in
            for imageData in imagesData {
                guard let uiImage = UIImage(data: imageData) else { return }
                context.beginPage()
                let imageRenderer = ImageRenderer(content: PDFImagePageView(uiImage: uiImage))
                imageRenderer.scale = displayScale
                if let uiImage = imageRenderer.uiImage {
                    uiImage.draw(at: .zero)
                }
            }
        }
        
        return fileURL
    }
}

