struct AlertError {
    var title: String
    var message: String
    var primaryButtonTitle: String
    var secondaryButtonTitle: String?
    var primaryAction: (() -> Void)?
    var secondaryAction: (() -> Void)?
}
