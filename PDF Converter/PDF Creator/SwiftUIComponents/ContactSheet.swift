import SwiftUI
import MessageUI

final class MailPresenter: NSObject, MFMailComposeViewControllerDelegate {
    static let shared = MailPresenter()
    
    var closeAction: (() -> Void)?
    
    private override init() { }
    
    func present(
        errorTitle: String,
        errorMessage: String,
        supportEmail: String
    ) {
        if !MFMailComposeViewController.canSendMail() {
            presentAlert(
                title: errorTitle,
                message: errorMessage,
                primaryAction: .OK
            )
            return
        }
        let picker = MFMailComposeViewController()
        picker.setToRecipients([supportEmail])
        picker.setSubject(UIApplication.shared.appName)
        picker.mailComposeDelegate = self
        UIApplication.shared.topViewController?.present(picker, animated: true)
    }
    
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ){
        UIApplication.shared.topViewController?.dismiss(animated: true)
        closeAction?()
    }
}

func presentAlert(
    title: String,
    message: String,
    primaryAction: UIAlertAction,
    secondaryAction: UIAlertAction? = nil,
    tertiaryAction: UIAlertAction? = nil
) {
    DispatchQueue.main.async {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(primaryAction)
        if let secondary = secondaryAction { alert.addAction(secondary) }
        if let tertiary = tertiaryAction { alert.addAction(tertiary) }
        UIApplication.shared.topViewController?.present(alert, animated: true)
    }
}

extension UIAlertAction {
    static var Cancel: UIAlertAction {
        UIAlertAction(title: "Cancel", style: .cancel)
    }
    
    static var OK: UIAlertAction {
        UIAlertAction(title: "OK", style: .cancel)
    }
}
