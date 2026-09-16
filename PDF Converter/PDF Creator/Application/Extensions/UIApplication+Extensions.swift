import UIKit
import StoreKit
import SafariServices

extension UIApplication {
    var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
    }

    var topViewController: UIViewController? {
        var topViewController = connectedScenes.compactMap {
            return ($0 as? UIWindowScene)?.windows
                                          .filter { $0.isKeyWindow  }
                                          .first?
                                          .rootViewController
        }
        .first
        
        if let presented = topViewController?.presentedViewController {
            topViewController = presented
        } else if let navController = topViewController as? UINavigationController {
            topViewController = navController.topViewController
        } else if let tabBarController = topViewController as? UITabBarController {
            topViewController = tabBarController.selectedViewController
        }
        return topViewController
    }
    
    func askRateApp() {
        guard let scene = foregroundActiveScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }

    /// For an explicit "Rate app" tap (e.g. in Settings). SKStoreReviewController
    /// is throttled by iOS to a few prompts per year, so a direct tap on a visible
    /// button can silently do nothing after the first couple of uses. Deep-linking
    /// to the App Store's review page always works.
    func openAppStoreReviewPage() {
        guard let url = URL(string: "\(EnvironmentValues.getValue().appId)?action=write-review") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func openTermsWebPage() {
        guard let url = URL(string: EnvironmentValues.getValue().terms) else { return }
        openSafariWebController(for: url)
    }
    
    func openPrivacyPolicyWebPage() {
        guard let url = URL(string: EnvironmentValues.getValue().privacy) else { return }
        openSafariWebController(for: url)
    }

    func openShareApp(localizedShareText: String) {
        let textToShare: [Any] = [
            localizedShareText,
            EnvironmentValues.getValue().appId
        ]

        let activityViewController = UIActivityViewController(
            activityItems: textToShare,
            applicationActivities: nil
        )
        
        topViewController?.present(activityViewController, animated: true)
    }
    
    func sharePDF(url: URL, from sourceView: UIView? = nil) {
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        // for iPad
        if let popover = activityViewController.popoverPresentationController, let view = sourceView ?? topViewController?.view {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        topViewController?.present(activityViewController, animated: true)
    }
}

private extension UIApplication {
    var foregroundActiveScene: UIWindowScene? {
        connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    }
    
    func openSafariWebController(for url: URL) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let vc = SFSafariViewController(url: url, configuration: config)
        topViewController?.present(vc, animated: true)
    }
}

