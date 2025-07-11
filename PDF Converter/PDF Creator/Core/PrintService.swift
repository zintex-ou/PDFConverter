import UIKit

final class PrintService {
    static func print(from url: URL, with name: String) {
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: [:])
        printInfo.outputType = .general
        printInfo.orientation = .portrait
        printInfo.jobName = name
        printController.printInfo = printInfo
        printController.printingItem = url
        
        printController.present(animated: true)
    }
}
