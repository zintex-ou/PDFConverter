import Foundation

final class FileManagerService {
    static let shared = FileManagerService()
    private let fileManager = FileManager.default
    private let directoryName = "PDFDocuments"
    
    private init() {}
    
    func getPDFDirectory() -> URL? {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let pdfDirectory = documentsDirectory.appendingPathComponent(directoryName)
        
        if !fileManager.fileExists(atPath: pdfDirectory.path) {
            do {
                try fileManager.createDirectory(at: pdfDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create PDF directory: \(error)")
                return nil
            }
        }
        
        return pdfDirectory
    }
    
    func getAllPDFDocuments() async throws -> [URL]? {
        guard let directory = getPDFDirectory() else { return nil }
        let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        return contents.filter { $0.pathExtension.lowercased() == "pdf" }
    }
    
    func deletePDFDocument(at url: URL) async throws {
        guard fileManager.fileExists(atPath: url.path) else { return }
        try fileManager.removeItem(at: url)
    }
    
    func renamePDFDocument(at url: URL, to newName: String) async throws -> URL? {
        let directory = url.deletingLastPathComponent()
        let newURL = directory.appendingPathComponent("\(newName).pdf")
        
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        
        try fileManager.moveItem(at: url, to: newURL)
        return newURL
    }
    
    @discardableResult
    func copyPDFToDocuments(from sourceURL: URL) async throws -> URL? {
        do {
            guard let destinationDirectory = getPDFDirectory() else { return nil }
            let destinationURL = destinationDirectory.appendingPathComponent(sourceURL.lastPathComponent)
            
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            return destinationURL
        } catch {
            print("Failed to copy or update PDF: \(error)")
            return nil
        }
    }
    
    
    func getTemporaryDirectory() -> URL {
        fileManager.temporaryDirectory
    }
}
