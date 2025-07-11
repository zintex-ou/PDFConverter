import SwiftUI

extension View {
    func scaleAnimation() -> some View {
        modifier(ScaleAnimationModifier())
    }
}

struct ScaleAnimationModifier: ViewModifier {
    @State var enablePulse: Bool = false
    
    func body(content: Content) -> some View {
        TimelineView(.animation(minimumInterval: 0.5, paused: false)) { timeline in
            ZStack {
                content
                    .scaleEffect(enablePulse ? 0.95 : 1)
            }
            .onChange(of: timeline.date) { newValue in
                withAnimation(.linear(duration: 0.5)) {
                    enablePulse.toggle()
                }
            }
        }
    }
}
