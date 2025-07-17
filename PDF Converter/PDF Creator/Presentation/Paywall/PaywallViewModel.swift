import UIKit
import Combine
import Reachability
import SwiftUI

@MainActor
final class PaywallViewModel: ObservableObject {
    @Published var products: [ProductModel] = []
    @Published var selectedProduct: ProductModel?
    @Published var isLoading: Bool = false
    @Published var shouldShowAlert: Bool = false
    @Published var shouldShowTryAgainAlert: Bool = false
    @Published var crossVisibleButton: Bool = false
    @Published var alertContent: AlertContent = .raw(title: "", subTitle: "")
    
    private var reachibility: Reachability?
    private let remoteConfigManager: RemoteConfigManager = .shared
    private let subscriptionService = SubscriptionService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.reachibility = try? Reachability()
        setupSubscriptions()
    }
    
    func getCrossButtonOpacity() -> Double {
        return remoteConfigManager.config.paywallConfig.opacityCloseButton
    }
    
    func tapOnCell(_ product: ProductModel) {
        selectedProduct = product
    }
    
    func getButtonTitle() -> LocalizedStringKey {
        if let selectedProduct, self.remoteConfigManager.config.paywallConfig.showPriceTitle {
            let badge = selectedProduct.badge ?? ""
            return "Subscribe for \(selectedProduct.price)/\(selectedProduct.description) \(badge.isEmpty ? "" : "with \(badge)")"
        } else {
            return "Continue"
        }
    }
    
    func tapOnPrivacyButton() {
        UIApplication.shared.openPrivacyPolicyWebPage()
    }
    
    func tapOnTermsButton() {
        UIApplication.shared.openTermsWebPage()
    }
    
    func fetchProduct() {
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        subscriptionService.loadProducts()
    }
    
    func shouldShowCrossButton() {
        let second = remoteConfigManager.config.paywallConfig.closeActionDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(second)) {
            self.crossVisibleButton = true
        }
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
        
        guard let selectedProduct else {
            alertContent = .raw(title: "Ooops...", subTitle: "Something went wrong.\nPlease try again.")
            self.shouldShowAlert = true
            return
        }
        
        Task {
            if let result = await subscriptionService.makePurchase(for: selectedProduct.id) {
                
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

extension PaywallViewModel {
    private func setupSubscriptions() {
        subscriptionService.$products
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] products in
                if !products.isEmpty {
                    self?.products = products
                    self?.selectedProduct = products.first
                }
            })
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
