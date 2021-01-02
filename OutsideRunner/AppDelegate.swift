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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window.makeKeyAndOrderFront(self)
        window.reload()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction
    func openPreferences(sender: AnyObject) {
        guard let configurationWindow = window.screenSaverView?.configureSheet else {
            return
        }

        window.beginSheet(configurationWindow) { [weak self] response in
            self?.window.reload()
        }
    }
}
