import Combine
import Foundation
import Adapty

class AdaptyProductProvider: ProductProvider {
    private let productsSubject = CurrentValueSubject<[ProductModel], Never>([])
    private let adaptyProductsSubject = CurrentValueSubject<[AdaptyPaywallProduct], Never>([])
    private let errorSubject = CurrentValueSubject<Error?, Never>(nil)
    
    var productsPublisher: AnyPublisher<[ProductModel], Never> {
        productsSubject.eraseToAnyPublisher()
    }
    
    var adaptyProductsPublisher: AnyPublisher<[AdaptyPaywallProduct], Never> {
        adaptyProductsSubject.eraseToAnyPublisher()
    }
    
    func loadProducts() async throws {
        let paywall = try await fetchPaywall()
        let adaptyProducts = try await fetchPaywallProducts(paywall: paywall)
        adaptyProductsSubject.send(adaptyProducts)
        try await Adapty.logShowPaywall(paywall)
        
        let mapped = adaptyProducts.map { product in
            let trialPeriod = product.subscriptionOffer?.subscriptionPeriod.numberOfUnits ?? 3
            let title = product.localizedTitle
            let description = product.localizedDescription
            let price = "\(product.currencySymbol ?? "$")\(NSDecimalNumber(decimal: product.price).floatValue)"
            let badge = product.subscriptionOffer?.paymentMode == .freeTrial ? "\(String(describing: trialPeriod)) days free trial" : nil
            
            return ProductModel(
                id: product.vendorProductId,
                title: title,
                description: description,
                price: price,
                badge: badge
            )
        }
        self.productsSubject.send(mapped)
    }
}

extension AdaptyProductProvider {
    private func fetchPaywall() async throws -> AdaptyPaywall {
        try await Adapty.getPaywall(placementId: "paywall_placement")
    }
    
    private func fetchPaywallProducts(paywall: AdaptyPaywall) async throws -> [AdaptyPaywallProduct] {
        try await Adapty.logShowPaywall(paywall)
        return try await Adapty.getPaywallProducts(paywall: paywall)
    }
}
