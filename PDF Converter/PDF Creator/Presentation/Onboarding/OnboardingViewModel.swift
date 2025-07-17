import Foundation
import SwiftUI
import Combine
import Reachability

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var pages: [OnboardingPage] = []
    @Published var currentIndex: Int = 0
    @Published var crossVisibleButton: Bool = false
    @Published var weeklyProduct: ProductModel?
    @Published var shouldShowAlert: Bool = false
    @Published var shouldShowTryAgainAlert: Bool = false
    @Published var alertContent: AlertContent = .raw(title: "", subTitle: "")
    @Published var isLoading: Bool = false
    
    private let remoteConfigManager: RemoteConfigManager = .shared
    private let subscriptionService = SubscriptionService.shared
    private var reachibility: Reachability?
    private var cancellables = Set<AnyCancellable>()
    
    var currentPage: OnboardingPage {
        pages[currentIndex]
    }
    
    init() {
        self.pages = OnboardingBuilder.buildPages()
        self.reachibility = try? Reachability()
        setupSubscriptions()
    }
    
    func tapOnContinue(onboardingCompletion: @escaping () -> Void) {
        if currentIndex < pages.count - 1 {
            currentIndex += 1
        } else {
            makePurchase(completion: onboardingCompletion)
        }
    }
    
    func getCrossButtonOpacity() -> Double {
        return remoteConfigManager.config.paywallConfig.opacityCloseButton
    }
    
    func tapOnPrivacyButton() {
        UIApplication.shared.openPrivacyPolicyWebPage()
    }
    
    func tapOnTermsButton() {
        UIApplication.shared.openTermsWebPage()
    }
    
    func getContinueButtonText() -> LocalizedStringKey {
        if currentIndex == pages.count - 1, self.remoteConfigManager.config.paywallConfig.showPriceTitle {
            return "With 3 days trial, then \(weeklyProduct?.price ?? "$6.99")/\(weeklyProduct?.description ?? "week")"
        } else {
            return "Continue"
        }
    }
    
    func shouldShowPrivacyView() -> Bool {
        currentIndex == pages.count - 1
    }
    
    func makePurchase(completion: @escaping () -> Void) {
        self.isLoading = true
        
        defer {
            self.isLoading = false
        }
        
        guard reachibility?.connection != .unavailable else {
            alertContent = .raw(title: "Bad Connection", subTitle: "Please, turn on the internet to get full access to the features")
            self.shouldShowAlert = true
            return
        }
        
        guard let weeklyProduct else {
            alertContent = .raw(title: "Ooops...", subTitle: "Something went wrong.\nPlease try again.")
            self.shouldShowAlert = true
            return
        }
        
        Task {
            if let result = await subscriptionService.makePurchase(for: weeklyProduct.id) {
                
                switch result {
                case .userCancelled:
                    alertContent = .raw(title: "Ooops...", subTitle: "Something went wrong.\nPlease try again.")
                    if remoteConfigManager.config.paywallConfig.showAlertAfterCanceledPurchase {
                        shouldShowTryAgainAlert = true
                    } else {
                        shouldShowAlert = true
                    }
                case .pending:
                    break
                case .success:
                    completion()
                }
            }
        }
    }
    
    func tapOnRestore(completion: @escaping () -> Void) {
        self.isLoading = true
        
        defer {
            self.isLoading = false
        }
        
        guard reachibility?.connection != .unavailable else {
            alertContent = .raw(title: "Bad Connection", subTitle: "Please, turn on the internet to get full access to the features")
            self.shouldShowAlert = true
            return
        }
        
        Task {
            if let isActive = await subscriptionService.restorePurchases(), isActive {
                completion()
            } else {
                alertContent = .raw(title: "No active subscription", subTitle: "You have no active subscriptions, please check your subscription status.")
                self.shouldShowAlert = true
            }
        }
    }
}

extension OnboardingViewModel {
    private func setupSubscriptions() {
        $currentIndex
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] index in
                guard let self else { return }
                
                switch index {
                case 1:
                    UIApplication.shared.askRateApp()
                case pages.count - 1:
                    self.fetchProduct()
                    self.shouldShowCrossButton()
                default: break
                }
            })
            .store(in: &cancellables)
        
        subscriptionService.$products
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] products in
                guard let self = self else { return }
                
                if let weekly = products.first(where: { $0.id.lowercased().contains("week") }) {
                    self.weeklyProduct = weekly
                    
                    if let lastPageIndex = self.pages.indices.last {
                        let price = weekly.price
                        let badge = weekly.badge ?? "3-days Trial"
                        let period = weekly.description
                        
                        self.pages[lastPageIndex] = OnboardingPage(
                            image: .BG_5,
                            title: "Unlock advanced creation!",
                            subtitle: "Unlock full PDF power with \(badge), then \(price) per \(period)"
                        )
                    }
                }
            })
            .store(in: &cancellables)
        
        subscriptionService.$subscriptionError
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] error in
                if let error {
                    self?.alertContent = error
                    self?.shouldShowAlert = true
                }
            })
            .store(in: &cancellables)
    }
    
    private func fetchProduct() {
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        subscriptionService.loadProducts()
    }
    
    private func shouldShowCrossButton() {
        let second = remoteConfigManager.config.paywallConfig.closeActionDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(second)) {
            self.crossVisibleButton = true
        }
    }
}
