import Cocoa

public protocol ScreenSaverInterface {
    static func make(frame: NSRect, isPreview: Bool) -> ScreenSaverInterface

//    @objc
//    optional func bar(baz: String)
}

public protocol Factory {
//    func makeInstance() -> SsX
}
