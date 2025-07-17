import SwiftUI

struct ProductModel: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let price: String
    let badge: String?
}
