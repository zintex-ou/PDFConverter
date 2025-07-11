import Foundation
import SwiftUI
import PDFKit

struct PDFReader: UIViewRepresentable {
    @Binding var currentPage: Int
    private let url: URL
    private let pdfView = PDFView()
    
    init(currentPage: Binding<Int>, url: URL) {
        self._currentPage = currentPage
        self.url = url
    }
    
    func makeUIView(context: Context) -> PDFView {
        pdfView.document = PDFDocument(url: self.url)
        pdfView.displayMode = .singlePageContinuous
        pdfView.autoScales = true
        pdfView.usePageViewController(true)
        pdfView.displayDirection = .horizontal
        pdfView.backgroundColor = UIColor(Color(hex: "#FAFAFA")) 
        
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(context.coordinator.handlePageChange),
            name: Notification.Name.PDFViewPageChanged,
            object: pdfView
        )
        
        NotificationCenter.default.addObserver(
                    context.coordinator,
                    selector: #selector(context.coordinator.handleTapOnPageNumber(_:)),
                    name: .tapOnPageNotification,
                    object: nil
                )
        
        return pdfView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(currentPage: $currentPage, pdfView: pdfView)
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        pdfView.scrollView?.showsVerticalScrollIndicator = false
        pdfView.scrollView?.showsHorizontalScrollIndicator = false
    }
    
    class Coordinator {
        @Binding var currentPage: Int
        private let pdfView: PDFView
        
        init(currentPage: Binding<Int>, pdfView: PDFView) {
            self._currentPage = currentPage
            self.pdfView = pdfView
        }
        
        @objc func handlePageChange(notification: Notification) {
            guard let pdfView = notification.object as? PDFView,
                  let currentPage = pdfView.currentPage,
                  let index = pdfView.document?.index(for: currentPage) else { return }
            
            DispatchQueue.main.async {
                self.currentPage = index
            }
        }
        
        @objc func handleTapOnPageNumber(_ notification: Notification) {
            guard let page = notification.userInfo?["page"] as? Int,
                  let document = pdfView.document,
                  page >= 0,
                  page < document.pageCount,
                  let pdfPage = document.page(at: page) else { return }
            
            DispatchQueue.main.async {
                self.pdfView.go(to: pdfPage)
            }
        }
    }
    
}

extension PDFView {
    var scrollView: UIScrollView? {
        guard let pageViewControllerContentView = subviews.first else { return nil }
        for view in pageViewControllerContentView.subviews {
            guard let scrollView = view as? UIScrollView else { continue }
            return scrollView
        }
        
        return nil
    }
}
