import Cocoa

enum KeyCode: UInt16 {
    case space = 0x31
}

class Window: NSWindow {
    var keyHandler: ((KeyCode) -> Void)?

    var screenSaverView: ScreenSaverInterface?

    override func keyDown(with event: NSEvent) {
        if let keyCode = KeyCode(rawValue: event.keyCode) {
            keyHandler?(keyCode)
            return
        }

        super.keyDown(with: event)
    }

    func reload() {
        self.screenSaverView?.stopAnimation()
        if let screenSaverView = screenSaverView as? NSView {
            screenSaverView.removeFromSuperview()
        }

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

        let instance = principalClass.init(frame: frame, isPreview: false)

        guard
            let view = instance as? NSView
        else {
            print("not a view, nooo")
            return
        }

        guard
            let contentView = contentView
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

        center()

        screenSaverView = instance

        instance.startAnimation()
    }
}
