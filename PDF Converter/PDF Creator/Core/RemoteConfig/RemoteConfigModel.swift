import Foundation

struct RemoteConfigModel: Codable, Equatable {
    static func == (lhs: RemoteConfigModel, rhs: RemoteConfigModel) -> Bool {
        return lhs.paywallConfig == rhs.paywallConfig &&
        lhs.enabledAppRatingRequest == rhs.enabledAppRatingRequest
    }
    
    struct PaywallConfig: Codable, Equatable {
        let closeActionDuration: Int
        let opacityCloseButton: Double
        let showAlertAfterCanceledPurchase: Bool
        let showPriceTitle: Bool
    }
    
    let paywallConfig: PaywallConfig
    let enabledAppRatingRequest: Bool
    
    static var `default`: RemoteConfigModel {
        .init(
            paywallConfig: PaywallConfig(
                closeActionDuration: 0,
                opacityCloseButton: 0.8,
                showAlertAfterCanceledPurchase: false,
                showPriceTitle: true
            ),
            enabledAppRatingRequest: false
        )
    }
}
