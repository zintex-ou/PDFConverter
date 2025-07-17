import SwiftUI

struct LoadingView: View {
    @State var degrees: Double = 0
    @State private var isVisible: Bool = false

    private let frameSize = 200.0
    private let lineWidth = 10.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
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
            .scaleEffect(isVisible ? 1 : 0.6)
            .opacity(isVisible ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
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
                    .transition(.scale.combined(with: .opacity))
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
