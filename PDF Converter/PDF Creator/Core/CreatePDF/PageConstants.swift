import Foundation

struct PageConstants {
    static let dotsPerInch: CGFloat = 72.0

    /// Countries that conventionally use US Letter; everyone else gets A4.
    private static let letterRegions: Set<String> = ["US", "CA", "MX", "PH", "CL", "CO", "VE", "PA", "DO", "GT", "CR"]

    private static var usesLetterFormat: Bool {
        guard let region = Locale.current.region?.identifier else { return false }
        return letterRegions.contains(region)
    }

    static var pageWidth: CGFloat { usesLetterFormat ? 8.5 : 8.27 }
    static var pageHeight: CGFloat { usesLetterFormat ? 11.0 : 11.69 }
}
