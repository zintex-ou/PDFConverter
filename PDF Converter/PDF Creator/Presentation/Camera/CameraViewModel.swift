import UIKit
import Photos
import AVFoundation
import SwiftUI
import Combine

class CameraViewModel: ObservableObject {
    
    @ObservedObject var cameraManager = CameraManager()
    
    @Published var isFlashOn = false
    @Published var showAlertError = false
    @Published var showSettingAlert = false
    @Published var isPermissionGranted: Bool = false
    @Published var capturedImage: UIImage?
    @Published var capturedImagesData: [Data] = []
    
    var alertError: AlertError!
    
    // Reference to the AVCaptureSession.
    var session: AVCaptureSession = .init()
    
    // Cancellable storage for Combine subscribers.
    private var cancelables = Set<AnyCancellable>()
    private let createPDFServcie: PDFService = .shared
    private let notificationService: NotificationService = .shared
    private let imageCompletion: ([Data]) -> Void
    
    init(imageCompletion: @escaping ([Data]) -> Void) {
        self.imageCompletion = imageCompletion
        
        // Initialize the session with the cameraManager's session.
        session = cameraManager.session
    }
    
    deinit {
        // Deinitializer to stop capturing when the ViewModel is deallocated.
        cameraManager.stopCapturing()
    }
    
    func switchCamera() {
        cameraManager.position = cameraManager.position == .back ? .front : .back
        cameraManager.switchCamera()
    }
    
    // Setup Combine bindings for handling publisher's emit values
    func setupBindings() {
        cameraManager.$shouldShowAlertView.sink { [weak self] value in
            // Update alertError and showAlertError based on cameraManager's state.
            self?.alertError = self?.cameraManager.alertError
            self?.showAlertError = value
        }
        .store(in: &cancelables)
        
        cameraManager.$capturedImageData.sink { [weak self] imageData in
            guard let imageData else { return }
            self?.capturedImage = UIImage(data: imageData)
            self?.capturedImagesData.append(imageData)
        }
        .store(in: &cancelables)
    }
    
    // Call when the capture button tap
    func captureImage() {
        cameraManager.captureImage()
    }
    
    func switchFlash() {
        isFlashOn.toggle()
        cameraManager.toggleTorch(tourchIsOn: isFlashOn)
    }
    
    func setFocus(point: CGPoint) {
        // Delegate focus configuration to the CameraManager.
        cameraManager.setFocusOnTap(devicePoint: point)
    }
    
    func zoom(with factor: CGFloat) {
        cameraManager.setZoomScale(factor: factor)
    }
    
    func checkForDevicePermission() {
        let videoStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch videoStatus {
        case .authorized:
            isPermissionGranted = true
            configureCamera()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self else { return }
                    
                    if granted {
                        self.isPermissionGranted = true
                        self.configureCamera()
                    } else {
                        self.isPermissionGranted = false
                        self.showSettingAlert = true
                    }
                }
            }
            
        case .denied, .restricted:
            isPermissionGranted = false
            showSettingAlert = true
            
        @unknown default:
            isPermissionGranted = false
            showSettingAlert = true
        }
    }
    
    // Configure the camera through the CameraManager to show a live camera preview.
    func configureCamera() {
        cameraManager.configureCaptureSession()
    }
    
    func tapOnConvertButton() {
        imageCompletion(capturedImagesData)
    }
}
