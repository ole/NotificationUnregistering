import Foundation

/// Abstract base class for various types of block-based notification observers.
/// Each subclass uses a different strategy for unregistering (or not) the notification observer.
/// The goal is to observe (ha!) the various behaviors.
class NotificationObserver: NSObject {
    /// The notification to observe
    let notification: Notification.Name
    /// An ID to identify this instance
    var number: Int

    init(notification: Notification.Name, number theNumber: Int) {
        self.notification = notification
        self.number = theNumber
        super.init()
    }

    override var description: String {
        return "<\(type(of: self))> number: \(number)"
    }
}

class WeakSelfObserverThatNeverUnregisters: NotificationObserver {
    var observerToken: Any? = nil
    static let title = "Observer never unregisters; uses [weak self] in block. ❌"
    static let message = """
        Observers:
        • use the standard block-based addObserver(forName:object:queue:using:) method.
        • store the returned observer token in a property.
        • take care to by use [weak self] in the block. ✅
        • never call NotificationCenter.removeObserver(_:). ❌

        Observe the console in Xcode when you tap the buttons.
        """

    override init(notification: Notification.Name, number theNumber: Int) {
        super.init(notification: notification, number: theNumber)
        observerToken = NotificationCenter.default.addObserver(forName: notification, object: nil, queue: nil) { [weak self] notification in
            print("Entering notification handler block")
            guard let strongSelf = self else { return }
            print("\(strongSelf) received \(notification.name.rawValue)")
        }
    }
}

class WeakSelfObserverThatUnregistersOnDeinit: NotificationObserver {
    var observerToken: Any? = nil
    static let title = "Observer unregisters in deinit; uses [weak self] in block. ✅"
    static let message = """
        Observers:
        • use the standard block-based addObserver(forName:object:queue:using:) method.
        • store the observer token in a property.
        • take care to use [weak self] in the block. ✅
        • explicitly call NotificationCenter.removeObserver(_:) in deinit. ✅

        Observe the console in Xcode when you tap the buttons.
        """

    override init(notification: Notification.Name, number theNumber: Int) {
        super.init(notification: notification, number: theNumber)
        observerToken = NotificationCenter.default.addObserver(forName: notification, object: nil, queue: nil) { [weak self] notification in
            print("Entering notification handler block")
            guard let strongSelf = self else { return }
            print("\(strongSelf) received \(notification.name.rawValue)")
        }
    }

    deinit {
        print("deinit \(self), observerToken is \(observerToken.map(String.init(reflecting:)) ?? "nil")")
        if let token = observerToken {
            print("Unregistering notification observer")
            NotificationCenter.default.removeObserver(token)
        }
    }
}

class StrongSelfObserverThatUnregistersOnDeinit: NotificationObserver {
    var observerToken: Any? = nil
    static let title = "Observer unregisters in deinit; uses strong self in block. ❌"
    static let message = """
        Observers:
        • use the standard block-based addObserver(forName:object:queue:using:) method.
        • store the observer token in a property.
        • strongly referencing self in the block. ❌
        • explicitly call NotificationCenter.removeObserver(_:) in deinit. ✅ But deinit is never called because of the reference cycle! ❌

        Observe the console in Xcode when you tap the buttons.
        """

    override init(notification: Notification.Name, number theNumber: Int) {
        super.init(notification: notification, number: theNumber)
        // Forgetting [weak self] produces a memory leak that also prevents propert unregistering because deinit is never called.
        observerToken = NotificationCenter.default.addObserver(forName: notification, object: nil, queue: nil) { notification in
            print("Entering notification handler block")
            print("\(self) received \(notification.name.rawValue)")
        }
    }

    deinit {
        print("deinit \(self), observerToken is \(observerToken.map(String.init(reflecting:)) ?? "nil")")
        if let token = observerToken {
            print("Unregistering notification observer")
            NotificationCenter.default.removeObserver(token)
        }
    }
}

class NotificationTokenObserver: NotificationObserver {
    var observerToken: NotificationToken? = nil
    static let title = "Observer stores the observer token in our custom NotificationToken wrapper class ✅"
    static let message = """
        Observers:
        • use the standard block-based addObserver(forName:object:queue:using:) method.
        • wrap the returned observer token in our custom NotificationToken and store that in a property. The wrapper class calls NotificationCenter.removeObserver(_:) in its deinit. ✅
        • take care to use [weak self] in the block. ✅
        • never call NotificationCenter.removeObserver(_:) themselves. ✅

        Observe the console in Xcode when you tap the buttons.
        """

    override init(notification: Notification.Name, number theNumber: Int) {
        super.init(notification: notification, number: theNumber)
        observerToken = NotificationCenter.default.observe(name: notification, object: nil, queue: nil) { [weak self] notification in
            print("Entering notification handler block")
            guard let strongSelf = self else { return }
            print("\(strongSelf) received \(notification.name.rawValue)")
        }
    }

    // No need for deinit, we just use it for logging
    deinit {
        print("deinit \(self)")
    }

    override var description: String {
        return "<\(type(of: self))> number: \(number)"
    }
}

extension NotificationCenter {
    /// Convenience wrapper for addObserver(forName:object:queue:using:) that
    /// returns our custom NotificationToken.
    func observe(name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> ()) -> NotificationToken {
        let token = addObserver(forName: name, object: obj, queue: queue, using: block)
        return NotificationToken(notificationCenter: self, token: token)
    }
}

/// Wraps the observer token received from NSNotificationCenter.addObserver(forName:object:queue:using:)
/// and automatically unregisters from the notification center on deinit.
final class NotificationToken: NSObject {
    let notificationCenter: NotificationCenter
    let token: Any

    init(notificationCenter: NotificationCenter = .default, token: Any) {
        self.notificationCenter = notificationCenter
        self.token = token
    }

    deinit {
        print("NotificationToken deinit: unregistering")
        notificationCenter.removeObserver(token)
    }
}
