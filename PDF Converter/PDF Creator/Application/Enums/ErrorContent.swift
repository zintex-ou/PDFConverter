import Foundation
import SwiftUI

enum ErrorContent: Error {
    
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
