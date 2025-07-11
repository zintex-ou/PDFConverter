struct InstrumentsBuilder {
    static func build(viewModel: PDFEditorViewModel) -> [InstrumentsItem] {
        [
            .init(icon: .property1AddPage, title: "Add page", comletion: viewModel.addPage),
            .init(icon: .property1Reorder, title: "Reorder", comletion: viewModel.reorder),
            .init(icon: .property1Share, title: "Share", comletion: viewModel.share),
            .init(icon: .property1Text, title: "Extract text", comletion: viewModel.extractText)
        ]
    }
}
