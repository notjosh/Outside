import Cocoa

class ConfigurationController: NSObject {
    @IBOutlet var window: NSWindow!
    @IBOutlet var muteAudioCheckbox: NSButton!
    @IBOutlet var randomiseOrderCheckbox: NSButton!
    @IBOutlet var maximumQualityPopUpButton: NSPopUpButton!

    let preferences = Preferences.shared

    let streamingQualities = StreamingQuality.allCases

    override init() {
        super.init()
        let myBundle = Bundle(for: ConfigurationController.self)
        myBundle.loadNibNamed("ConfigureSheet", owner: self, topLevelObjects: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        muteAudioCheckbox.state = preferences.muteAudio ? .on : .off
        randomiseOrderCheckbox.state = preferences.randomisePlayback ? .on : .off

        maximumQualityPopUpButton.removeAllItems()
        maximumQualityPopUpButton.addItems(withTitles: streamingQualities.map { $0.title })

        if let idx = streamingQualities.firstIndex(of: preferences.highestQuality) {
            maximumQualityPopUpButton.selectItem(at: idx)
        }
    }

    @IBAction func updateDefaults(_ sender: AnyObject) {
        preferences.muteAudio = muteAudioCheckbox.state == .on
        preferences.randomisePlayback = randomiseOrderCheckbox.state == .on
        preferences.highestQuality = streamingQualities[maximumQualityPopUpButton.indexOfSelectedItem]
    }

    @IBAction func closeConfigureSheet(_ sender: AnyObject) {
        window?.sheetParent?.endSheet(window!)
    }
}
