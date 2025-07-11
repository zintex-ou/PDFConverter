import SwiftUI

struct CameraSwitchButton: View {
    
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(systemName: "camera.rotate.fill")
                        .foregroundColor(.white))
        }
    }
}
