import Combine

protocol ProductProvider {
    var productsPublisher: AnyPublisher<[ProductModel], Never> { get }
    func loadProducts() async throws
}
