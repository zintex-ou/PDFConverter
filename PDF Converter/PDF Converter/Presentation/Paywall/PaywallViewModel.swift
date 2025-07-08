import Foundation
import Combine

@MainActor
final class PaywallViewModel: ObservableObject {
    @Published var products: [ProductModel] = []
    @Published var selectedProduct: ProductModel?
    @Published var isLoading: Bool = false
    @Published var shouldShowAlert: Bool = false
    @Published var alertContent: ErrorContent = .raw(title: "", subTitle: "")
    
    private var cancellables = Set<AnyCancellable>()
    private let subscriptionService = SubscriptionService.shared
    
    init() {
        setupSubscriptions()
    }
    
    func getOpasityForClose() -> Double {
        1
    }
    
    func loadProducts() {
        subscriptionService.loadProducts()
    }
    
    func purchase() {
        guard let product = selectedProduct else {
            alertContent = .raw(title: "Product not found", subTitle: "")
            shouldShowAlert = true
            return
        }
        
        Task {
            let result = try await subscriptionService.makePurchase(for: product.id)
        }
    }
    
    func tapOnCell(_ product: ProductModel) {
        selectedProduct = product
    }
    
    func getButtonTitle() -> String {
        "Continue"
    }
    
    private func setupSubscriptions() {
        subscriptionService.$products
            .receive(on: RunLoop.main)
            .removeDuplicates()
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
