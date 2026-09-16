import UIKit
import Reachability
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isSubscribed: Bool = false
    @Published var alertContent: AlertContent = .raw(title: "", subTitle: "")
    @Published var shouldShowAlert: Bool = false
    
    private(set) var settingsCell: [SettingsItem] = []
    private var reachibility: Reachability?
    private let subscriptionService = SubscriptionService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.settingsCell = SettingsBuilder.buildCell(viewModel: self)
        setupSubscriptions()
        self.reachibility = try? Reachability()
    }
    
    func reateUs() {
        UIApplication.shared.openAppStoreReviewPage()
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
    
    func restorePurchase() {
        guard reachibility?.connection != .unavailable else {
            alertContent = .raw(
                title: "Bad Connection",
                subTitle: "Please, turn on the internet to get full access to the features"
            )
            shouldShowAlert = true
            return
        }
        
        Task {
            if let isActive = await subscriptionService.restorePurchases(), isActive {
                alertContent = .raw(
                    title: "Subscription Restored",
                    subTitle: "Your subscription has been successfully restored. Enjoy full access to all features."
                )
            } else {
                alertContent = .raw(
                    title: "No active subscription",
                    subTitle: "You have no active subscriptions, please check your subscription status."
                )
            }
            
            shouldShowAlert = true
        }
    }
}

extension SettingsViewModel {
    private func setupSubscriptions() {
        subscriptionService.$isSubscribed
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.isSubscribed = value
            }
            .store(in: &cancellables)
        
        subscriptionService.$subscriptionError
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] error in
                if let error {
                    self?.alertContent = error
                    self?.shouldShowAlert = true
                }
            })
            .store(in: &cancellables)
    }
}
