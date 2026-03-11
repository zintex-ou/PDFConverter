import SwiftUI

struct LoadingView: View {
    @State var degrees: Double = 0
    @State private var isVisible: Bool = false
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(isVisible ? 0.1 : 0)
                .ignoresSafeArea()
            Group {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundStyle(.ultraThinMaterial)
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.12), radius: 4)
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.large)
                    .tint(Color(hex: "#D53131"))
            }
            .opacity(isVisible ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.2)) {
                isVisible = true
            }
            
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                degrees += 360
            }
        }
        .onDisappear {
            withAnimation(.easeInOut(duration: 0.2)) {
                isVisible = false
            }
        }
    }
}

struct LoadingPresenter: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                LoadingView()
                    .zIndex(1)
            }
        }
    }
}

extension View {
    func loading(isPresented: Binding<Bool>) -> some View {
        modifier(LoadingPresenter(isPresented: isPresented))
    }
}

#Preview {
    LoadingView()
}
