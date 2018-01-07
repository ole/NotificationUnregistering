import Foundation
@testable import NotificationUnregistering
import XCTest

let testNotification = Notification.Name(rawValue: "NotificationUnregisteringTestsNotification")

class NotificationUnregisteringTests: XCTestCase {
    func test_Variant1_FailingToUnregister_CausesBlockToStayAliveEvenAfterTokenIsReleased() {
        var counter = 0
        var token: Any? = nil
        token = NotificationCenter.default.addObserver(forName: testNotification, object: nil, queue: nil) { _ in
            counter += 1
        }
        // Posting notification increments counter (as expected)
        NotificationCenter.default.post(name: testNotification, object: nil)
        XCTAssertEqual(counter, 1)
        // Release observation token
        if token != nil { token = nil }
        // Post notification again
        NotificationCenter.default.post(name: testNotification, object: nil)
        // Increments counter again(!)
        XCTAssertEqual(counter, 2)
    }

    func test_Variant2_Unregistering_EndsObservation() {
        var counter = 0
        var token: Any? = nil
        token = NotificationCenter.default.addObserver(forName: testNotification, object: nil, queue: nil) { _ in
            counter += 1
        }
        // Posting notification increments counter (as expected)
        NotificationCenter.default.post(name: testNotification, object: nil)
        XCTAssertEqual(counter, 1)
        // Unregister
        token.map { NotificationCenter.default.removeObserver($0) }
        token = nil
        // Post notification again
        NotificationCenter.default.post(name: testNotification, object: nil)
        // Observer block isn't executed again
        XCTAssertEqual(counter, 1)
    }

    func test_Variant3_UnregisteringInDeinit_DoesntHelpIfObserverBlockCapturedSelf() {
        var externalCounter = 0

        class TestObserver {
            var token: Any? = nil
            var internalCounter: Int = 0
            init(observerBlock: @escaping () -> ()) {
                token = NotificationCenter.default.addObserver(forName: testNotification, object: nil, queue: nil) { _ in
                    // Captures self strongly
                    self.internalCounter += 1
                    observerBlock()
                }
            }
            deinit {
                token.map { NotificationCenter.default.removeObserver($0) }
            }
        }

        var observer: TestObserver? = TestObserver {
            externalCounter += 1
        }
        // Posting notification increments counter (as expected)
        NotificationCenter.default.post(name: testNotification, object: nil)
        XCTAssertEqual(externalCounter, 1)
        // Release observer
        if observer != nil { observer = nil }
        // Post notification again
        NotificationCenter.default.post(name: testNotification, object: nil)
        // Increments counter again(!)
        XCTAssertEqual(externalCounter, 2)
    }

    func test_Variant4_NotificationTokenWrapper_UnregistersOnDeinit() {
        var counter = 0
        var token: NotificationToken? = nil
        token = NotificationCenter.default.observe(name: testNotification, object: nil, queue: nil) { _ in
            counter += 1
        }
        // Posting notification increments counter (as expected)
        NotificationCenter.default.post(name: testNotification, object: nil)
        XCTAssertEqual(counter, 1)
        // Destroy observation token
        if token != nil { token = nil }
        // Post notification again
        NotificationCenter.default.post(name: testNotification, object: nil)
        // Observer block isn't executed again
        XCTAssertEqual(counter, 1)
    }
}
