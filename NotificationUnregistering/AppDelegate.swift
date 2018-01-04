import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let tabBarVC = UITabBarController()
        tabBarVC.viewControllers = [
            UINavigationController(rootViewController: ViewController(
                title: "Variant 1",
                notification: Notification.Name("Tab_1_Notification"),
                headline: WeakSelfObserverThatNeverUnregisters.title,
                message: WeakSelfObserverThatNeverUnregisters.message,
                createObserver: { WeakSelfObserverThatNeverUnregisters(notification: $0, number: $1) }
            )),
            UINavigationController(rootViewController: ViewController(
                title: "Variant 2",
                notification: Notification.Name("Tab_2_Notification"),
                headline: WeakSelfObserverThatUnregistersOnDeinit.title,
                message: WeakSelfObserverThatUnregistersOnDeinit.message,
                createObserver: { WeakSelfObserverThatUnregistersOnDeinit(notification: $0, number: $1) }
            )),
            UINavigationController(rootViewController: ViewController(
                title: "Variant 3",
                notification: Notification.Name("Tab_3_Notification"),
                headline: StrongSelfObserverThatUnregistersOnDeinit.title,
                message: StrongSelfObserverThatUnregistersOnDeinit.message,
                createObserver: { StrongSelfObserverThatUnregistersOnDeinit(notification: $0, number: $1) }
            )),
            UINavigationController(rootViewController: ViewController(
                title: "Variant 4",
                notification: Notification.Name("Tab_4_Notification"),
                headline: NotificationTokenObserver.title,
                message: NotificationTokenObserver.message,
                createObserver: { NotificationTokenObserver(notification: $0, number: $1) }
            )),
        ]
        window?.rootViewController = tabBarVC
        window?.makeKeyAndVisible()
        return true
    }
}
