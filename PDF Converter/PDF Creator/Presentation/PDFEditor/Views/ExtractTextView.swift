import SwiftUI

struct ExtractTextView: View {
    @ObservedObject var viewModel: PDFEditorViewModel
    @EnvironmentObject private var coordinator: Coordinator
    
    init(viewModel: PDFEditorViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: .zero) {
                navigationView
                
                content
            }
            
            textCopiedAlert
                .padding(.horizontal, -16)
                .opacity(viewModel.shouldSHowCopiedAlert ? 1 : 0)
        }
        .padding(.horizontal, 16)
        .background(Color(hex: "#FAFAFA"))
        .loading(isPresented: .init(
            get: { viewModel.extractTextState == .loading },
            set: { _ in }
        ))
        .onAppear {
            viewModel.extractText()
        }
        .onChange(of: viewModel.currentPage) {_ in
            viewModel.extractText()
        }
        .animation(.default, value: viewModel.extractTextState)
        .animation(.default, value: viewModel.shouldSHowCopiedAlert)
    }
    
    var navigationView: some View {
        HStack(spacing: 12) {
            Button {
                coordinator.popToBack()
            } label: {
                Image(.property1Arrow)
            }
            
            Spacer()
        }
        .padding(.bottom, 8)
        .background(Color(hex: "#FAFAFA"))
    }
    
    var bottomView: some View {
        HStack {
            if case let .success(text) = viewModel.extractTextState {
                Spacer()
                
                Button {
                    viewModel.coppyTextToPasteboard()
                } label: {
                    VStack(spacing: 4) {
                        Image(.property1Copy)
                        
                        Text("Copy")
                            .font(.init(style: .regular, size: 12))
                            .foregroundStyle(.black)
                    }
                }
                
                Spacer()
                
                
                ShareLink(item: text) {
                    VStack(spacing: 4) {
                        Image(.property1Share)
                        
                        Text("Share")
                            .font(.init(style: .regular, size: 12))
                            .foregroundStyle(.black)
                    }
                }
                
                Spacer()
            }
        }
        .padding(.top, 16)
        .background(Color(hex: "#FAFAFA"))
    }
    
    var textCopiedAlert: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                Image(.selectActive)
                
                Text("Text copied!")
                    .foregroundStyle(.black)
                    .font(.init(style: .regular, size: 16))
            }
            .padding(.all, 19)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    @ViewBuilder
    var content: some View {
        switch viewModel.extractTextState {
        case .idle, .loading:
            Color.clear
        case .success(let extractedText):
            ScrollView {
                VStack(alignment: .leading) {
                    Text(extractedText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.init(style: .regular, size: 16))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
            }
            
            Divider()
            
            bottomView
        case .empty, .failed:
            VStack {
                Spacer()
                
                Text("Not found text")
                    .font(.init(style: .semiBold, size: 16))
                
                Spacer()
            }
        }
    }
}

#Preview {
    ExtractTextView(
        viewModel: .init(
            pdfMetaData: .init(url: URL(string: "")!, creationDate: .now, pageCount: 1)
        )
    )
}
