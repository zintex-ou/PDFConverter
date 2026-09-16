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
        
        #if DEBUG
        self.isSubscribed = true
        self.configureShortCut()
        #endif
    }
    
    func start() async {
        #if DEBUG
        self.isSubscribed = true
        self.configureShortCut()
        await setupAdaptyProvider()
        return
        #endif
        
        await fetchProfile()
        await setupAdaptyProvider()
    }
    
    func isActivityPurchases() -> Bool {
        #if DEBUG
        return true
        #else
        guard let expiresAt = self.keychainManager.purchasesExpiresAt else { return false }
        return Date() < expiresAt
        #endif
    }
    
    func loadProducts() {
        Task { await loadProductsAsync() }
    }

    func loadProductsAsync() async {
        do {
            try await provider.loadProducts()
        } catch {
            #if DEBUG
            self.isSubscribed = true
            self.configureShortCut()
            return
            #endif
            
            if let error = AdaptyErrorManager.init(error: error).error {
                self.subscriptionError = error
            }
        }
    }
    
    func makePurchase(for productId: String) async -> AdaptyPurchaseResult? {
        #if DEBUG
        self.isSubscribed = true
        self.configureShortCut()
        return nil
        #else
        guard let product = adaptyProducts.first(where: { $0.vendorProductId == productId }) else {
            self.subscriptionError = .raw(title: "Product not found", subTitle: "")
            return nil
        }
        
        do {
            let purchasesResult = try await Adapty.makePurchase(product: product)
            saveExpiresPurchasesToStorage(profile: purchasesResult.profile)
            
            let isPremium = purchasesResult.profile?.accessLevels.contains(where: { $0.value.isActive }) ?? false
            self.isSubscribed = isPremium
            
            if isPremium {
                self.configureShortCut()
            } else {
                UIApplication.shared.shortcutItems = []
            }
            
            return purchasesResult
        } catch {
            if let error = AdaptyErrorManager.init(error: error).error {
                self.subscriptionError = error
            }
            return nil
        }
        #endif
    }
    
    func restorePurchases() async -> Bool? {
        #if DEBUG
        self.isSubscribed = true
        self.configureShortCut()
        return true
        #else
        do {
            let profile = try await Adapty.restorePurchases()
            saveExpiresPurchasesToStorage(profile: profile)
            let isPremium = profile.accessLevels.contains(where: { $0.value.isActive })
            self.isSubscribed = isPremium
            
            if isPremium {
                self.configureShortCut()
            } else {
                UIApplication.shared.shortcutItems = []
            }
            
            return isPremium
        } catch {
            if let error = AdaptyErrorManager.init(error: error).error {
                self.subscriptionError = error
            }
            return nil
        }
        #endif
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
        #if DEBUG
        self.isSubscribed = true
        self.configureShortCut()
        return
        #else
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
        #endif
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
        #if DEBUG
        self.isSubscribed = true
        self.configureShortCut()
        return
        #else
        saveExpiresPurchasesToStorage(profile: profile)
        let isPremium = profile.accessLevels.contains(where: { $0.value.isActive })
        self.isSubscribed = isPremium
        
        if !isPremium {
            UIApplication.shared.shortcutItems = []
        } else {
            self.configureShortCut()
        }
        #endif
    }
}
