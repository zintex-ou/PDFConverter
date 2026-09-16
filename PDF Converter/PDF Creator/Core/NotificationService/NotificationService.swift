import Foundation

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    func post<T>(event: NotificationEvent, object: T?) {
        NotificationCenter.default.post(
            name: NSNotification.Name(event.rawValue),
            object: object
        )
    }
    
    @discardableResult
    func observe<T>(event: NotificationEvent, handler: @escaping (T) -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(event.rawValue),
            object: nil,
            queue: .main
        ) { notification in
            if let object = notification.object as? T {
                handler(object)
            }
        }
    }

    func stopObserving(_ token: NSObjectProtocol) {
        NotificationCenter.default.removeObserver(token)
    }
}

