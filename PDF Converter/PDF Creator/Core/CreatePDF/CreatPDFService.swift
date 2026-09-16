import Foundation
import PDFKit
import SwiftUI
import _PhotosUI_SwiftUI
import SwiftUI
import Vision

@MainActor
final class PDFService {
    static let shared = PDFService()
    
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
        destinationURL: URL
    ) async throws -> URL? {
        guard let basePDF = PDFDocument(url: basePDFURL) else {
            return nil
        }
        
        guard let additionalPDF = PDFDocument(url: additionalPDFURL) else {
            return nil
        }
        
        let mergedPDF = PDFDocument()
        
        for index in 0..<basePDF.pageCount {
            if let page = basePDF.page(at: index) {
                mergedPDF.insert(page, at: mergedPDF.pageCount)
            }
        }
        
        for index in 0..<additionalPDF.pageCount {
            if let page = additionalPDF.page(at: index) {
                mergedPDF.insert(page, at: mergedPDF.pageCount)
            }
        }
        
        let originalFileName = basePDFURL.deletingPathExtension().lastPathComponent
        let uniqueName = "\(originalFileName)_merged_\(UUID().uuidString).pdf"
        let finalURL = destinationURL.appendingPathComponent(uniqueName)
        
        guard mergedPDF.write(to: finalURL) else {
            return nil
        }
        
        return finalURL
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

        let originalFileName = sourceURL.deletingPathExtension().lastPathComponent
        let uniqueName = "\(originalFileName)_reordered_\(UUID().uuidString).pdf"
        let finalURL = directoryURL.appendingPathComponent(uniqueName)

        if rearrangedPDF.write(to: finalURL) {
            return finalURL
        } else {
            return nil
        }
    }
    
    // MARK: - Extract text
    
    func extractText(from url: URL, pageIndex: Int) async throws -> String? {
        guard let document = PDFDocument(url: url),
              let page = document.page(at: pageIndex) else {
            return nil
        }
        
        if let pageText = page.string?.trimmingCharacters(in: .whitespacesAndNewlines),
           !pageText.isEmpty {
            return pageText
        }
        
        guard let image = renderPDFPageToImage(page) else {
            return nil
        }
        
        return try await recognizeText(from: image)
    }
    
    private func renderPDFPageToImage(_ page: PDFPage) -> UIImage? {
        let pageRect = page.bounds(for: .mediaBox)
        
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let image = renderer.image { context in
            UIColor.white.set()
            context.fill(CGRect(origin: .zero, size: pageRect.size))
            
            context.cgContext.translateBy(x: 0, y: pageRect.height)
            context.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            page.draw(with: .mediaBox, to: context.cgContext)
        }
        
        return image
    }
    
    private func recognizeText(from image: UIImage) async throws -> String? {
        guard let cgImage = image.cgImage else { return nil }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let text = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                continuation.resume(returning: text.isEmpty ? nil : text)
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.automaticallyDetectsLanguage = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
