import Foundation
import PDFKit
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
    
    func createPDFData(from imagesData: [Data], displayScale: CGFloat, in directory: URL?) async throws -> URL? {
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = metaData as [String: Any]
        let renderer = UIGraphicsPDFRenderer(bounds: rect, format: format)
        let date = Date()
        
        let fileName = "PDF_\(date.timeIntervalSince1970).pdf"
        guard let documentsDirectory = directory else {
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
    
    func mergePDFs(
        basePDFURL: URL,
        additionalPDFURL: URL,
        directory: URL
    ) async throws -> URL? {
        guard let basePDF = PDFDocument(url: basePDFURL) else {
            return nil
        }
        
        guard let additionalPDF = PDFDocument(url: additionalPDFURL) else {
            return nil
        }
        
        let basePageCount = basePDF.pageCount
        
        for i in 0..<additionalPDF.pageCount {
            if let page = additionalPDF.page(at: i) {
                basePDF.insert(page, at: basePageCount + i)
            }
        }
        
        let date = Date()
        let fileName = "PDF_\(date.timeIntervalSince1970).pdf"
        let fileURL = directory.appendingPathComponent(fileName)
        
        guard basePDF.write(to: fileURL) else {
            return nil
        }
        
        return fileURL
    }

    func rearrangePages(
        from sourceURL: URL,
        newOrder: [Int],
        to directoryURL: URL
    ) async throws -> URL? {
        guard let originalPDF = PDFDocument(url: sourceURL) else { return nil }

        let rearrangedPDF = PDFDocument()

        for (newIndex, pageIndex) in newOrder.enumerated() {
            guard let page = originalPDF.page(at: pageIndex) else { continue }
            rearrangedPDF.insert(page, at: newIndex)
        }

        let originalName = sourceURL.deletingPathExtension().lastPathComponent
        let newFileName = "\(originalName)"
        let destinationURL = directoryURL.appendingPathComponent(newFileName)

        if rearrangedPDF.write(to: destinationURL) {
            return destinationURL
        } else {
            return nil
        }
    }

}
