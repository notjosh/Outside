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
        let principalClass = screenSaverBundle.principalClass
        let x = principalClass as? NSObject.Type
        let y = principalClass?.alloc()

//        let z = y?.responds(to: #selector(ScreenSaverInterface.bar(baz:)))
        guard
            let xx = principalClass as? NSObjectProtocol.Type,
            let ssaver = principalClass as? ScreenSaverInterface.Type
        else {
            fatalError("Could not instantiate screen saver class from bundle")
        }

//        
//        let instance = ssaver.init(frame: window.frame, isPreview: false)
//
//        guard
//            let view = instance as? NSView
//        else {
//            print("not a view, nooo")
//            return
//        }
//
//        view.frame = window.frame
//
//        print("hello")
//
//        window.contentView = view
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}


