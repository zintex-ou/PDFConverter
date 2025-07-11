import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var shortcutItem: UIApplicationShortcutItem!
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let shortcut = connectionOptions.shortcutItem else { return }
        shortcutItem = shortcut
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        guard let shortcutItem else { return }
        handle(shortcutItem: shortcutItem)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let handled = handle(shortcutItem: shortcutItem)
        completionHandler(handled)
    }
    
    @discardableResult
    func handle(shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let shortcutType = ShortCutType(rawValue: shortcutItem.type) else { return false }
        
        switch shortcutType {
        case .mail:
            MailPresenter.shared.present(
                errorTitle: "Email Client",
                errorMessage: "You need to login in your native apple mail app ",
                supportEmail: EnvironmentValues.getValue().email
            )
        }
        return true
    }
}
