Do you have to manually unregister block-based NotificationCenter observers?

**tl;dr:** yes. (Tested on iOS 11.2.)

For more info, see [the accompanying article](https://oleb.net/blog/2018/01/notificationcenter-removeobserver/).

This is the test app I used to test the behavior of [`NotificationCenter.addObserver(forName:object:queue:using:)`](https://developer.apple.com/documentation/foundation/notificationcenter/1411723-addobserver) under various scenarios.
