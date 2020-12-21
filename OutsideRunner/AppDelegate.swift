import Cocoa

import ObjectiveC

@objc
protocol Foo {
    func `init`(frame: NSRect, isPreview: Bool)
    func bar(baz: String)
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var window: Window!

    var outsideView: NSView?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard
            let url = Bundle.main.url(forResource: "Outside", withExtension: "saver"),
            let bundle = Bundle(url: url)
        else {
            fatalError("Cannot find bundle `Outside.saver`")
        }

        do {
            try bundle.loadAndReturnError()
        } catch {
            fatalError("Cannot load bundle, error: \(error)")
        }

        guard
            let principalClass = bundle.principalClass as? ScreenSaverInterface.Type
        else {
            fatalError("Could not instantiate screen saver class from bundle")
        }

        let instance = principalClass.init(frame: .zero, isPreview: false)

        guard
            let view = instance as? NSView
        else {
            print("not a view, nooo")
            return
        }

        guard
            let contentView = window.contentView
        else {
            fatalError("Where's the content view?")
        }

        let frame = contentView.bounds

        view.frame = frame
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        window.center()
        window.makeKeyAndOrderFront(self)

        window.keyHandler = { code in
            switch code {
            case .space:
                instance.next()
            }
        }

        instance.startAnimation()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
