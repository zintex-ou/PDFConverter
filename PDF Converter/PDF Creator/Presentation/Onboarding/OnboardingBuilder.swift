import SwiftUI

struct OnboardingBuilder {
    static func buildPages() -> [OnboardingPage] {
        [
            OnboardingPage(image: .BG_1, title: "Convert files in seconds!", subtitle: "Quickly turn documents, images, and more into high-quality PDFs"),
            OnboardingPage(image: .BG_2, title: "We value your feedback!", subtitle: "Leave a review and help us make the application even more customized"),
            OnboardingPage(image: .BG_3, title: "Scan & Convert instantly!", subtitle: "Use your camera to scan paper documents and convert them into PDFs with just one tap"),
            OnboardingPage(image: .BG_4, title: "Extract text with ease!", subtitle: "Turn images and PDF into editable text\nin an instant"),
            OnboardingPage(image: .BG_5, title: "Enjoy unlimited conversions!", subtitle: "Unlock full PDF power with 3-days Trial, then $6,99 per week"),
        ]
    }
}
