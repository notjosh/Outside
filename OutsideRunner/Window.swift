import Cocoa

enum KeyCode: UInt16 {
    case space = 0x31
}

class Window: NSWindow {
    var keyHandler: ((KeyCode) -> Void)?

    override func keyDown(with event: NSEvent) {
        if let keyCode = KeyCode(rawValue: event.keyCode) {
            keyHandler?(keyCode)
            return
        }

        super.keyDown(with: event)
    }
}
