import AVFoundation
import Photos
import UIKit

class CameraDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    
    private let completion: (Data?) -> Void
    
    init(completion: @escaping (Data?) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            print("CameraManager: Error while capturing photo: \(error)")
            completion(nil)
            return
        }
        
        if let imageData = photo.fileDataRepresentation() {
            completion(imageData)
        } else {
            print("CameraManager: Image not fetched.")
        }
    }
}
