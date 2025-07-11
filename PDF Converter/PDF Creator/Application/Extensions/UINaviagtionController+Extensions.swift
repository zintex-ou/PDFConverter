import UIKit

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    
    private static var viewControllersCount = 3
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    static func changeViewControllersCount(_ count: Int) {
        self.viewControllersCount = count
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > UINavigationController.viewControllersCount
    }
}
