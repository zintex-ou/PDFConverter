import SwiftUI

extension Font {
    init(customFont: CustomFonts = .urbanist, style: CustomFontStyle, size: CGFloat) {
        let fontName = customFont.rawValue + style.rawValue
        self = Font.custom(fontName, size: size)
    }
}
