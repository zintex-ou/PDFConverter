import Foundation
import SwiftUI

enum AlertContent: Error, Equatable {
    
    case raw(title: LocalizedStringKey, subTitle: LocalizedStringKey)
    
    var title: LocalizedStringKey {
        switch self {
        case let .raw(title, _): return title
        }
    }
    
    var subTitle: LocalizedStringKey {
        switch self {
        case let .raw(_, subTitle): return subTitle
        }
    }
}
