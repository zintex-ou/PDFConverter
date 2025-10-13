import SwiftUI
import SwiftUI

struct CameraView: View {
    @StateObject private var viewModel: CameraViewModel
    @EnvironmentObject private var coordinator: Coordinator
    @State private var isFocused = false
    @State private var focusLocation: CGPoint = .zero
    @State private var isScaled = false // To scale the view
    @State private var currentZoomFactor: CGFloat = 1.0
    
    init(imageCompletion: @escaping ([Data]) -> Void) {
        self._viewModel = StateObject(
            wrappedValue: CameraViewModel(imageCompletion: imageCompletion)
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            coordinator.dismissFullScreenCover()
                        } label: {
                            Text("Cancel")
                                .foregroundStyle(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.switchFlash()
                        }, label: {
                            Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                .font(.system(size: 20, weight: .medium, design: .default))
                        })
                        .accentColor(viewModel.isFlashOn ? .yellow : .white)
                    }
                    .padding(16)
                    
                    CameraPreview(session: viewModel.session) { tapPoint in
                        isFocused = true
                        focusLocation = tapPoint
                        viewModel.setFocus(point: tapPoint)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    .gesture(
                        MagnificationGesture() // Apply a MagnificationGesture to the CameraPreview
                            .onChanged { value in
                                // Calculate the change in zoom factor
                                self.currentZoomFactor += value - 1.0
                                
                                // Ensure the zoom factor stays within a specific range
                                self.currentZoomFactor = min(max(self.currentZoomFactor, 0.5), 10)
                                
                                // Call a method to update the zoom level
                                self.viewModel.zoom(with: currentZoomFactor)
                            })
                    
                    ZStack {
                        HStack {
                            PhotoThumbnail(image: $viewModel.capturedImage)
                            Spacer()
                            
                            if !viewModel.capturedImagesData.isEmpty {
                                Button {
                                    viewModel.tapOnConvertButton()
                                    coordinator.dismissFullScreenCover()
                                } label: {
                                    Text("Convert (\(viewModel.capturedImagesData.count))")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 2)
                                        .background(.white)
                                        .clipShape(Capsule())
                                }
                            }
                            
                            //                        CameraSwitchButton { viewModel.switchCamera() }
                        }
                        .padding(16)
                        
                        CaptureButton { viewModel.captureImage() }
                    }
                }
                .alert(isPresented: $viewModel.showAlertError) {
                    Alert(
                        title: Text(viewModel.alertError.title),
                        message: Text(viewModel.alertError.message),
                        dismissButton:
                                .default(
                                    Text(viewModel.alertError.primaryButtonTitle),
                                    action: {
                                        viewModel.alertError.primaryAction?()
                                    })
                    )
                }
                .alert(isPresented: $viewModel.showSettingAlert) {
                    Alert(
                        title: Text("Warning"),
                        message: Text("Application doesn't have all permissions to use camera, please change privacy settings."),
                        dismissButton:
                                .default(Text("Go to settings"), action: {
                                    self.openSettings()
                                })
                    )
                }
                .onAppear {
                    viewModel.setupBindings()
                    viewModel.checkForDevicePermission()
                }
                
                if isFocused {
                    FocusView(position: $focusLocation)
                        .scaleEffect(isScaled ? 0.8 : 1)
                        .onAppear {
                            // Add a springy animation effect for visual appeal.
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                                self.isScaled = true
                                // Return to the default state after 0.6 seconds for an elegant user experience.
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    self.isFocused = false
                                    self.isScaled = false
                                }
                            }
                        }
                }
            }
            .animation(.default, value: viewModel.capturedImagesData.count)
        }
    }
    
    // use to open app's setting
    func openSettings() {
        let settingsUrl = URL(string: UIApplication.openSettingsURLString)
        if let url = settingsUrl {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

#Preview {
    CameraView(imageCompletion: {_ in })
}
