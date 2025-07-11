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

