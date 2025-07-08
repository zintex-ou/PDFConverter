import Combine

class MockProductProvider: ProductProvider {
    private let subject = CurrentValueSubject<[ProductModel], Never>([
        ProductModel(id: "weekly", title: "Weekly", price: "$6.99", badge: "3 days free trial"),
        ProductModel(id: "monthly", title: "Monthly", price: "$19.99", badge: nil),
        ProductModel(id: "yearly", title: "Yearly", price: "$49.99", badge: nil),
    ])
    
    var productsPublisher: AnyPublisher<[ProductModel], Never> {
        subject.eraseToAnyPublisher()
    }

    func loadProducts() async throws {}
}
