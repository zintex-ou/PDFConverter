struct SettingsBuilder {
    static func buildCell(viewModel: SettingsViewModel) -> [SettingsItem] {
        [
            .init(icon: .property1Like, title: "Rate app", completion: viewModel.reateUs),
            .init(icon: .property1Share, title: "Share app", completion: viewModel.shareApp),
            .init(icon: .property1Contact, title: "Contact us", completion: viewModel.contactUs),
            .init(icon: .property1ShieldCheck, title: "Privacy policy", completion: viewModel.openPrivacy),
            .init(icon: .property1File, title: "Terms of use", completion: viewModel.openTerms)
        ]
    }
}
