import UIKit
import Photos
import AVFoundation
import SwiftUICore
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
    
    // Check for camera device permission.
    func checkForDevicePermission() {
        let videoStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if videoStatus == .authorized {
            // If Permission granted, configure the camera.
            isPermissionGranted = true
            configureCamera()
        } else if videoStatus == .notDetermined {
            // In case the user has not been asked to grant access we request permission
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { _ in })
        } else if videoStatus == .denied {
            // If Permission denied, show a setting alert.
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
