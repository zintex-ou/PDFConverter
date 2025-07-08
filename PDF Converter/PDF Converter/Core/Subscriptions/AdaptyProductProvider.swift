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
        try await Adapty.logShowPaywall(paywall)
        
        let mapped = adaptyProducts.map { product in
            ProductModel(
                id: product.vendorProductId,
                title: product.localizedTitle,
                price: product.localizedPrice ?? "\(product.price)",
                badge: product.subscriptionPeriod?.unit == .week ? "3 days free trial" : nil
            )
        }
        self.productsSubject.send(mapped)
    }
}

extension AdaptyProductProvider {
    private func fetchPaywall() async throws -> AdaptyPaywall {
        try await Adapty.getPaywall(placementId: "in.app.placement")
    }
    
    private func fetchPaywallProducts(paywall: AdaptyPaywall) async throws -> [AdaptyPaywallProduct] {
        try await Adapty.logShowPaywall(paywall)
        return try await Adapty.getPaywallProducts(paywall: paywall)
    }
}
