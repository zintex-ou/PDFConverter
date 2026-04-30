import Foundation
import Adapty

struct AdaptyErrorManager {
    
    var error: AlertContent?
    var adaptyErrorCode: AdaptyError.ErrorCode = .unknown
    
    init(error: Error) {
        self.error = getErrorText(error: error)
        adaptyErrorCode = errorCode(error: error)
    }
    
    private func errorCode(error: Error) -> AdaptyError.ErrorCode {
        guard let adaptyError = error as? AdaptyError else {
            return .unknown
        }
        return adaptyError.adaptyErrorCode
    }
    
    private func getErrorText(error: Error) -> AlertContent {
        guard let adaptyError = error as? AdaptyError else {
            return .raw(title: "Error", subTitle: "An unexpected error occurred.")
        }
        
        switch adaptyError.adaptyErrorCode {
        case .unknown:
            return .raw(title: "Error", subTitle: "An unexpected error occurred.")
        case .clientInvalid:
            return .raw(title: "Error", subTitle: "You are not allowed to perform this action.")
        case .paymentCancelled:
            return .raw(title: "Payment Cancelled", subTitle: "Your payment request was canceled.")
        case .paymentInvalid:
            return .raw(title: "Payment Invalid", subTitle: "One of the payment details was not recognized.")
        case .paymentNotAllowed:
            return .raw(title: "Payment Not Allowed", subTitle: "You are not authorized to make payments.")
        case .storeProductNotAvailable:
            return .raw(title: "Product Not Available", subTitle: "The item you requested is not available in the store.")
        case .cloudServicePermissionDenied:
            return .raw(title: "Permission Denied", subTitle: "You haven't allowed access to Cloud service information.")
        case .cloudServiceNetworkConnectionFailed:
            return .raw(title: "Bad Connection", subTitle: "Please, turn on the internet to get full access to the features")
        case .cloudServiceRevoked:
            return .raw(title: "Cloud Service Revoked", subTitle: "Permission to use this cloud service has been revoked.")
        case .privacyAcknowledgementRequired:
            return .raw(title: "Privacy Acknowledgement Required", subTitle: "You need to acknowledge Apple’s privacy policy for Apple Music.")
        case .unauthorizedRequestData:
            return .raw(title: "Unauthorized Request Data", subTitle: "The app is attempting to use unauthorized data.")
        case .invalidOfferIdentifier:
            return .raw(title: "Invalid Offer Identifier", subTitle: "The offer identifier is invalid.")
        case .invalidSignature:
            return .raw(title: "Invalid Signature", subTitle: "The signature in a payment discount is not valid.")
        case .missingOfferParams:
            return .raw(title: "Missing Offer Params", subTitle: "Some parameters are missing in a payment discount.")
        case .invalidOfferPrice:
            return .raw(title: "Invalid Offer Price", subTitle: "The price specified in App Store Connect is no longer valid.")
        case .noProductIDsFound:
            return .raw(title: "No Product IDs Found", subTitle: "No In-App Purchase product identifiers were found.")
        case .productRequestFailed:
            return .raw(title: "Product Request Failed", subTitle: "Unable to fetch available In-App Purchase products at the moment.")
        case .cantMakePayments:
            return .raw(title: "Can't Make Payments", subTitle: "In-App Purchases are not allowed on this device.")
        case .cantReadReceipt:
            return .raw(title: "Can't Read Receipt", subTitle: "Can't find a valid receipt.")
        case .productPurchaseFailed:
            return .raw(title: "Product Purchase Failed", subTitle: "Product purchase failed.")
        case .refreshReceiptFailed:
            return .raw(title: "Refresh Receipt Failed", subTitle: "Refresh receipt failed.")
        case .notActivated:
            return .raw(title: "Not Activated", subTitle: "You need to be authenticated to perform requests.")
        case .badRequest:
            return .raw(title: "Bad Request", subTitle: "The request made is not valid.")
        case .serverError:
            return .raw(title: "Bad Connection", subTitle: "Please, turn on the internet to get full access to the features")
        case .networkFailed:
            return .raw(title: "Bad Connection", subTitle: "Please, turn on the internet to get full access to the features")
        case .decodingFailed:
            return .raw(title: "Decoding Failed", subTitle: "Unable to understand the response received.")
        case .encodingFailed:
            return .raw(title: "Encoding Failed", subTitle: "Failed to encode parameters for the request.")
        case .analyticsDisabled:
            return .raw(title: "Analytics Disabled", subTitle: "We can't handle analytics events since you've opted out.")
        case .wrongParam:
            return .raw(title: "Wrong Param", subTitle: "An incorrect parameter was passed.")
        case .activateOnceError:
            return .raw(title: "Activate Once Error", subTitle: "It is not possible to call the .activate method more than once.")
        case .profileWasChanged:
            return .raw(title: "Profile Was Changed", subTitle: "The user profile was changed during the operation.")
        case .unsupportedData:
            return .raw(title: "Unsupported Data", subTitle: "Data is unsupported.")
        case .fetchTimeoutError:
            return .raw(title: "Fetch Timeout Error", subTitle: "Timeout error.")
        case .operationInterrupted:
            return .raw(title: "Operation Interrupted", subTitle: "This operation was interrupted by the system.")
        case .fetchSubscriptionStatusFailed:
            return .raw(title: "Fetch Failed", subTitle: "Unable to fetch subscription status. Please try again later.")
        case .paymentPendingError:
            return .raw(title: "Fetch Failed", subTitle: "Unable to fetch subscription status. Please try again later.")
        case .unknownTransactionId:
            return .raw(title: "Fetch Failed", subTitle: "Unable to fetch subscription status. Please try again later.")
        case .unidentifiedUserLogout:
            return .raw(title: "Fetch Failed", subTitle: "Unable to fetch subscription status. Please try again later.")
        }
    }
}
