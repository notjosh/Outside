import Cocoa

import ObjectiveC

@objc
protocol Foo {
    func `init`(frame: NSRect, isPreview: Bool)
    func bar(baz: String)
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var window: NSWindow!
    var screenSaverBundle: Bundle

    var outsideView: NSView?

    override init() {
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

        screenSaverBundle = bundle

        super.init()
    }


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard
            let principalClass = screenSaverBundle.principalClass as? ScreenSaverInterface.Type
        else {
            fatalError("Could not instantiate screen saver class from bundle")
        }

        guard
            let contentView = window.contentView
        else {
            fatalError("Where's the content view?")
        }

        let frame = contentView.bounds

        let instance = principalClass.init(frame: frame, isPreview: false)

        guard
            let view = instance as? NSView
        else {
            print("not a view, nooo")
            return
        }

        print("hello")

        instance.startAnimation()

        view.frame = frame
        contentView.addSubview(view)

        window.center()
        window.makeKeyAndOrderFront(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}


