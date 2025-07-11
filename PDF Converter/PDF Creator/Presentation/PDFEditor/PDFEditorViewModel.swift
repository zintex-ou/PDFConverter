import UIKit

final class PDFEditorViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    private(set) var pdfMetaData: PDFMetadata
    private(set) var instruments: [InstrumentsItem] = []
    
    init(pdfMetaData: PDFMetadata) {
        self.pdfMetaData = pdfMetaData
        self.instruments = InstrumentsBuilder.build(viewModel: self)
    }
    
    func addPage() {
        
    }
    
    func reorder() {
        
    }
    
    func share() {
        UIApplication.shared.sharePDF(url: pdfMetaData.url)
    }
    
    func extractText() {
        
    }
}
