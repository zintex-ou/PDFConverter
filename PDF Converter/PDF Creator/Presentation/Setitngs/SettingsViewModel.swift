import UIKit

final class SettingsViewModel: ObservableObject {
    private(set) var settingsCell: [SettingsItem] = []
    
    init() {
        self.settingsCell = SettingsBuilder.buildCell(viewModel: self)
    }
    
    func reateUs() {
        UIApplication.shared.askRateApp()
    }
    
    func shareApp() {
        UIApplication.shared.openShareApp(localizedShareText: "")
    }
    
    func contactUs() {
        MailPresenter.shared.present(
            errorTitle: "Email Client",
            errorMessage: "You need to login in your native apple mail app ",
            supportEmail: EnvironmentValues.getValue().email
        )
    }
    
    func openPrivacy() {
        UIApplication.shared.openPrivacyPolicyWebPage()
    }
    
    func openTerms() {
        UIApplication.shared.openTermsWebPage()
    }
}
