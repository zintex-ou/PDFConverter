import SwiftUI

@main
struct PDF_ConverterApp: App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            CoordinatorView()
        }
    }
}
