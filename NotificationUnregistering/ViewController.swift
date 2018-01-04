import UIKit

class ViewController: UIViewController {
    let notification: Notification.Name
    /// The view controllers manages an array of notification observers
    private var observers: [Any] = []
    /// Factory function to to create an observer (dependency injection)
    private let createObserver: (_ notification: Notification.Name, _ number: Int) -> Any

    private let headline: String
    private let message: String

    private let stack = UIStackView(arrangedSubviews: [])
    private let headlineLabel = UILabel(frame: .zero)
    private let messageLabel = UILabel(frame: .zero)

    init(title: String, notification: Notification.Name, headline: String, message: String, createObserver: @escaping (_ notification: Notification.Name, _ number: Int) -> Any) {
        self.notification = notification
        self.headline = headline
        self.message = message
        self.createObserver = createObserver
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func loadView() {
        super.loadView()
        view.backgroundColor = .white

        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            stack.bottomAnchor.constraintLessThanOrEqualToSystemSpacingBelow(view.layoutMarginsGuide.bottomAnchor, multiplier: 1),
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])

        headlineLabel.numberOfLines = 0
        headlineLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)

        let postNotifcationButton = UIButton(type: .system)
        postNotifcationButton.setTitle("Post notification", for: .normal)
        postNotifcationButton.addTarget(self, action: #selector(didTapPostNotification), for: .touchUpInside)

        let createObserverButton = UIButton(type: .system)
        createObserverButton.setTitle("Create observer", for: .normal)
        createObserverButton.addTarget(self, action: #selector(didTapCreateObserver), for: .touchUpInside)

        let releaseObserverButton = UIButton(type: .system)
        releaseObserverButton.setTitle("Release observer", for: .normal)
        releaseObserverButton.addTarget(self, action: #selector(didTapReleaseObserver), for: .touchUpInside)

        stack.addArrangedSubview(headlineLabel)
        stack.addArrangedSubview(messageLabel)
        stack.addArrangedSubview(postNotifcationButton)
        stack.addArrangedSubview(createObserverButton)
        stack.addArrangedSubview(releaseObserverButton)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headlineLabel.text = headline
        messageLabel.text = message
    }

    @objc func didTapPostNotification() {
        print("Posting \(notification.rawValue)")
        NotificationCenter.default.post(name: notification, object: self)
    }

    @objc func didTapCreateObserver() {
        let new = createObserver(notification, observers.count + 1)
        observers.append(new)
        print("Created \(new)")
    }

    @objc func didTapReleaseObserver() {
        guard !observers.isEmpty else {
            print("There are no observers!")
            return
        }
        let deleted = observers.removeLast()
        print("Released observer \(deleted)")
    }
}
