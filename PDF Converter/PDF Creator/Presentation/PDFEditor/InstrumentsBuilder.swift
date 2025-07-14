struct InstrumentsBuilder {
    static func build(viewModel: PDFEditorViewModel) -> [InstrumentsItem] {
        [
            .init(type: .addPage, icon: .property1AddPage, title: "Add page", comletion: viewModel.addPage),
            .init(type: .reorder, icon: .property1Reorder, title: "Reorder", comletion: viewModel.reorderPage),
            .init(type: .share, icon: .property1Share, title: "Share", comletion: viewModel.share),
            .init(type: .extractText, icon: .property1Text, title: "Extract text", comletion: viewModel.extractTextPage)
        ]
    }
}
