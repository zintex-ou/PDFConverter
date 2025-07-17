import Combine

class MockProductProvider: ProductProvider {
    private let subject = CurrentValueSubject<[ProductModel], Never>([
        ProductModel(id: "weekly.subscription.trial", title: "Weekly", description: "week", price: "$6.99", badge: "3 days free trial"),
        ProductModel(id: "monthly.subscription", title: "Monthly", description: "month", price: "$19.99", badge: nil),
        ProductModel(id: "yearly.subscription", title: "Yearly", description: "year", price: "$49.99", badge: nil),
    ])
    
    var productsPublisher: AnyPublisher<[ProductModel], Never> {
        subject.eraseToAnyPublisher()
    }

    func loadProducts() async throws {}
}
