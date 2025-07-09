import SwiftUI

extension View {
    func scaleAnimation() -> some View {
        modifier(ScaleAnimationModifier())
    }
}

struct ScaleAnimationModifier: ViewModifier {
    @State private var enablePulse: Bool = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(enablePulse ? 0.95 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    enablePulse.toggle()
                }
            }
    }
}
