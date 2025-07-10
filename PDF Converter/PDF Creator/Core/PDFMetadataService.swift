import Foundation
import PDFKit

struct PDFMetadata: Identifiable {
    let id = UUID()
    let title: String?
    let url: URL
    let creationDate: Date?
    let pageCount: Int
}

enum PDFMetadataError: Error {
    case downloadFailed
    case invalidPDF
}

final class PDFMetadataService {
    static func fetchMetadata(from url: URL) async throws -> PDFMetadata {
        let (localURL, _) = try await URLSession.shared.download(from: url)

        guard let pdfDocument = PDFDocument(url: localURL) else {
            throw PDFMetadataError.invalidPDF
        }

        let attributes = pdfDocument.documentAttributes
        var title = attributes?[PDFDocumentAttribute.titleAttribute] as? String
        
        if title == nil {
            title = url.lastPathComponent
        }
        
        let creationDate = attributes?[PDFDocumentAttribute.creationDateAttribute] as? Date
        let pageCount = pdfDocument.pageCount

        return PDFMetadata(title: title, url: url, creationDate: creationDate, pageCount: pageCount)
    }
}
