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
                
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(viewModel.extractedText ?? "Not found text")
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
            }
            
            textCopiedAlert
                .padding(.horizontal, -16)
                .opacity(viewModel.shouldSHowCopiedAlert ? 1 : 0)
        }
        .padding(.horizontal, 16)
        .background(Color(hex: "#FAFAFA"))
        .onAppear {
            viewModel.extractText()
        }
        .onChange(of: viewModel.currentPage) {_ in
            viewModel.extractText()
        }
        .animation(.default, value: viewModel.extractedText)
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
            
            if let text = viewModel.extractedText {
                ShareLink(item: text) {
                    VStack(spacing: 4) {
                        Image(.property1Share)
                        
                        Text("Share")
                            .font(.init(style: .regular, size: 12))
                            .foregroundStyle(.black)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 16)
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
}

#Preview {
    ExtractTextView(
        viewModel: .init(
            pdfMetaData: .init(url: URL(string: "")!, creationDate: .now, pageCount: 1)
        )
    )
}
