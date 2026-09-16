import Foundation
import PDFKit
import SwiftUI
import _PhotosUI_SwiftUI
import SwiftUI
import Vision
import CoreImage

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
    
    // MARK: - Filters, compression, watermark, split

    func applyFilter(
        _ filter: PDFFilterOption,
        to sourceURL: URL,
        destinationDirectory: URL
    ) async throws -> URL? {
        try await rebuildDocument(from: sourceURL, destinationDirectory: destinationDirectory, suffix: "filtered") { image in
            Self.applyCIFilter(filter, to: image)
        }
    }

    func compress(
        _ level: PDFCompressionLevel,
        url: URL,
        destinationDirectory: URL
    ) async throws -> URL? {
        try await rebuildDocument(from: url, destinationDirectory: destinationDirectory, suffix: "compressed") { image in
            Self.compressImage(image, level: level)
        }
    }

    func applyWatermark(
        text: String,
        to url: URL,
        destinationDirectory: URL
    ) async throws -> URL? {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return try await rebuildDocument(from: url, destinationDirectory: destinationDirectory, suffix: "watermarked") { image in
            Self.drawWatermark(text, on: image)
        }
    }

    /// Extracts the given page indices into a brand-new PDF, leaving the source untouched.
    func extractPages(
        _ indices: [Int],
        from url: URL,
        destinationDirectory: URL
    ) async throws -> URL? {
        guard let document = PDFDocument(url: url), !indices.isEmpty else { return nil }

        let newDocument = PDFDocument()
        for (newIndex, pageIndex) in indices.sorted().enumerated() {
            guard let page = document.page(at: pageIndex) else { continue }
            newDocument.insert(page, at: newIndex)
        }
        guard newDocument.pageCount > 0 else { return nil }

        let originalFileName = url.deletingPathExtension().lastPathComponent
        let uniqueName = "\(originalFileName)_split_\(UUID().uuidString).pdf"
        let finalURL = destinationDirectory.appendingPathComponent(uniqueName)

        return newDocument.write(to: finalURL) ? finalURL : nil
    }

    private func rebuildDocument(
        from sourceURL: URL,
        destinationDirectory: URL,
        suffix: String,
        transform: (UIImage) -> UIImage
    ) async throws -> URL? {
        guard let document = PDFDocument(url: sourceURL) else { return nil }

        var images: [UIImage] = []
        for i in 0..<document.pageCount {
            guard let page = document.page(at: i),
                  let rendered = renderPDFPageToImage(page) else { continue }
            images.append(transform(rendered))
        }
        guard !images.isEmpty else { return nil }

        let newDocument = PDFDocument()
        for (index, image) in images.enumerated() {
            guard let page = PDFPage(image: image) else { continue }
            newDocument.insert(page, at: index)
        }
        guard newDocument.pageCount > 0 else { return nil }

        let originalFileName = sourceURL.deletingPathExtension().lastPathComponent
        let uniqueName = "\(originalFileName)_\(suffix)_\(UUID().uuidString).pdf"
        let finalURL = destinationDirectory.appendingPathComponent(uniqueName)

        return newDocument.write(to: finalURL) ? finalURL : nil
    }

    private static let ciContext = CIContext()

    private static func applyCIFilter(_ filter: PDFFilterOption, to image: UIImage) -> UIImage {
        guard filter != .original, let ciImage = CIImage(image: image) else { return image }

        let output: CIImage?
        switch filter {
        case .original:
            output = ciImage
        case .blackAndWhite:
            let mono = CIFilter(name: "CIColorMonochrome")
            mono?.setValue(ciImage, forKey: kCIInputImageKey)
            mono?.setValue(CIColor(color: .white), forKey: "inputColor")
            mono?.setValue(1.0, forKey: "inputIntensity")
            output = mono?.outputImage
        case .highContrast:
            let controls = CIFilter(name: "CIColorControls")
            controls?.setValue(ciImage, forKey: kCIInputImageKey)
            controls?.setValue(1.35, forKey: "inputContrast")
            output = controls?.outputImage
        }

        guard let output, let cgImage = ciContext.createCGImage(output, from: output.extent) else { return image }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    private static func compressImage(_ image: UIImage, level: PDFCompressionLevel) -> UIImage {
        let resized = resize(image, maxDimension: level.maxDimension)
        guard let data = resized.jpegData(compressionQuality: level.jpegQuality),
              let reloaded = UIImage(data: data) else { return resized }
        return reloaded
    }

    private static func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let longestSide = max(image.size.width, image.size.height)
        guard longestSide > maxDimension else { return image }

        let scale = maxDimension / longestSide
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    private static func drawWatermark(_ text: String, on image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { ctx in
            image.draw(at: .zero)

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: image.size.width * 0.14),
                .foregroundColor: UIColor(red: 0.835, green: 0.192, blue: 0.192, alpha: 0.55) // #D53131
            ]
            let attributedText = NSAttributedString(string: text, attributes: attributes)
            let textSize = attributedText.size()

            ctx.cgContext.saveGState()
            ctx.cgContext.translateBy(x: image.size.width / 2, y: image.size.height / 2)
            ctx.cgContext.rotate(by: -.pi / 4)
            attributedText.draw(at: CGPoint(x: -textSize.width / 2, y: -textSize.height / 2))
            ctx.cgContext.restoreGState()
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
