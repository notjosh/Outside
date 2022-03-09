import Cocoa

import ObjectiveC
import Carbon.HIToolbox.Events

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var window: Window!

    var outsideView: NSView?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window.keyHandler = { [weak self] code in
            switch Int(code) {
            case kVK_Space:
                self?.window.screenSaverView?.next()
                return true
            case kVK_ANSI_M:
                self?.window.screenSaverView?.moveMetadata()
                return true
            default:
                return false
            }
        }

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
