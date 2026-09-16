import Foundation

enum PDFFilterOption: CaseIterable, Equatable, Hashable {
    case original
    case blackAndWhite
    case highContrast

    var title: String {
        switch self {
        case .original: return "Original (Remove Filter)"
        case .blackAndWhite: return "Black & White"
        case .highContrast: return "High Contrast"
        }
    }
}

enum PDFCompressionLevel: CaseIterable, Hashable {
    case best
    case balanced
    case small

    var title: String {
        switch self {
        case .best: return "Best Quality"
        case .balanced: return "Balanced"
        case .small: return "Smallest File Size"
        }
    }

    var jpegQuality: CGFloat {
        switch self {
        case .best: return 0.8
        case .balanced: return 0.5
        case .small: return 0.3
        }
    }

    var maxDimension: CGFloat {
        switch self {
        case .best: return 2200
        case .balanced: return 1600
        case .small: return 1200
        }
    }
}
