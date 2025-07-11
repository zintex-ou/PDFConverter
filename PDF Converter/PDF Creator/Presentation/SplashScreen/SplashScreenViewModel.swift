import UIKit

final class SplashScreenViewModel: ObservableObject {
    func changeViewControllres(count: Int) {
        UINavigationController.changeViewControllersCount(count)
    }
}
