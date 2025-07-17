import Combine
import UIKit
import Adapty

@MainActor
final class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    
    @Published private(set) var products: [ProductModel] = []
    @Published private(set) var isSubscribed = false
    @Published private(set) var subscriptionError: AlertContent? = nil
    
    private var provider: ProductProvider
    private let keychainManager: KeychainManager = .init()
    private var adaptyProducts: [AdaptyPaywallProduct] = []
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        provider = MockProductProvider()
        subscribeToProvider()
        
        Adapty.activate(EnvironmentValues.getValue().adapty,
                        customerUserId: userIdKey)
        Adapty.delegate = self
    }
    
    func start() async {
        await fetchProfile()
        await setupAdaptyProvider()
    }
    
    func isActivityPurchases() -> Bool {
        guard let expiresAt = self.keychainManager.purchasesExpiresAt else { return false }
        return Date() < expiresAt
    }
    
    func loadProducts() {
        Task {
            do {
                try await provider.loadProducts()
            } catch {
                if let error = AdaptyErrorManager.init(error: error).error {
                    self.subscriptionError = error
                }
            }
        }
    }
    
    func makePurchase(for productId: String) async -> AdaptyPurchaseResult? {
        guard let product = adaptyProducts.first(where: { $0.vendorProductId == productId }) else {
            self.subscriptionError = .raw(title: "Product not found", subTitle: "")
            return nil
        }
        
        do {
            let purchasesResult = try await Adapty.makePurchase(product: product)
            saveExpiresPurchasesToStorage(profile: purchasesResult.profile)
            
            let isPremium = purchasesResult.profile?.accessLevels.contains(where: { $0.value.isActive }) ?? false
            self.isSubscribed = isPremium
            
            return purchasesResult
        } catch {
            if let error = AdaptyErrorManager.init(error: error).error {
                self.subscriptionError = error
            }
            return nil
        }
    }
    
    func restorePurchases() async -> Bool? {
        do {
            let profile = try await Adapty.restorePurchases()
            saveExpiresPurchasesToStorage(profile: profile)
            let isPremium = profile.accessLevels.contains(where: { $0.value.isActive })
            self.isSubscribed = isPremium
            return isPremium
        } catch {
            if let error = AdaptyErrorManager.init(error: error).error {
                self.subscriptionError = error
            }
            return nil
        }
    }
}

extension SubscriptionService {
    private var userIdKey: String {
        if let userIdKey = self.keychainManager.userIdKey {
            return userIdKey
        } else {
            let userIdKey = UUID().uuidString
            keychainManager.userIdKey = userIdKey
            return userIdKey
        }
    }
    
    private func setupAdaptyProvider() async {
        provider = AdaptyProductProvider()
        subscribeToProvider()
        loadProducts()
    }
    
    private func fetchProfile() async {
        do {
            let profile = try await Adapty.getProfile()
            saveExpiresPurchasesToStorage(profile: profile)
            let isPremium = profile.accessLevels.contains(where: { $0.value.isActive })
            self.isSubscribed = isPremium
        } catch {
            self.isSubscribed = isActivityPurchases()
            if let error = AdaptyErrorManager.init(error: error).error {
                self.subscriptionError = error
            }
        }
    }
    
    private func configureShortCut() {
        let shortcutItem = UIApplicationShortcutItem(
            type: ShortCutType.mail.rawValue,
            localizedTitle: "Stop Subscription",
            localizedSubtitle: "Message us to learn the unsubscribe process.",
            icon: UIApplicationShortcutIcon(type: .mail),
            userInfo: nil
        )
        UIApplication.shared.shortcutItems = [shortcutItem]
    }
    
    private func saveExpiresPurchasesToStorage(profile: AdaptyProfile?) {
        guard let profile else { return }
        keychainManager.purchasesExpiresAt = profile.accessLevels["premium"]?.expiresAt
    }
    
    private func subscribeToProvider() {
        provider.productsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] products in
                guard let self = self else { return }
                self.products = products
            }
            .store(in: &cancellables)
        
        if let adaptyProvider = provider as? AdaptyProductProvider {
            adaptyProvider.adaptyProductsPublisher
                .receive(on: RunLoop.main)
                .dropFirst()
                .sink { [weak self] adaptyProducts in
                    if !adaptyProducts.isEmpty {
                        self?.adaptyProducts = adaptyProducts
                    }
                }
                .store(in: &cancellables)
        }
    }
}

extension SubscriptionService: AdaptyDelegate {
    func didLoadLatestProfile(_ profile: AdaptyProfile) {
        saveExpiresPurchasesToStorage(profile: profile)
        let isPremium = profile.accessLevels.contains(where: { $0.value.isActive })
        self.isSubscribed = isPremium
        
        if !isPremium {
            UIApplication.shared.shortcutItems = []
        } else {
            self.configureShortCut()
        }
    }
}
