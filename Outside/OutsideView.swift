import AVKit
import AVFoundation
import ScreenSaver

class OutsideView: ScreenSaverView, ScreenSaverInterface {
    lazy var configurationController = ConfigurationController()

    let playlist = Playlist()
    let vimeo = Vimeo()
    let preferences = Preferences()

    let player: AVPlayer
    let playerLayer: AVPlayerLayer

    let metadataContainer: NSView
    let metadataTextField: NSTextField

    var metadataVisibleTimer: Timer?

    deinit {
        metadataVisibleTimer?.invalidate()
        metadataVisibleTimer = nil
    }
    
    required override init(frame: NSRect, isPreview: Bool) {
        // Radar# FB7486243, legacyScreenSaver.appex always returns true, unlike what used
        // to happen in previous macOS versions, see documentation here : https://developer.apple.com/documentation/screensaver/screensaverview/1512475-init$
        var preview = true

        // We can workaround that bug by looking at the size of the frame
        // It's always 296.0 x 184.0 when running in preview mode
        if frame.width > 400 && frame.height > 300 {
            preview = false
        }

        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)

        metadataContainer = NSView(frame: .zero)
        metadataTextField = NSTextField(labelWithString: "")

        super.init(frame: frame, isPreview: preview)!

        wantsLayer = true

        playerLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        playerLayer.frame = bounds
        playerLayer.opacity = 1
        playerLayer.videoGravity = .resizeAspectFill

        layer?.backgroundColor = NSColor.black.cgColor
        layer?.frame = bounds

        layer?.addSublayer(playerLayer)

        player.allowsExternalPlayback = false
        player.isMuted = preferences.muteAudio

        addSubview(metadataContainer)
        metadataContainer.addSubview(metadataTextField)

        metadataContainer.translatesAutoresizingMaskIntoConstraints = false
        metadataContainer.wantsLayer = true
        metadataContainer.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.4).cgColor
        metadataContainer.layer?.cornerRadius = 5

        metadataTextField.translatesAutoresizingMaskIntoConstraints = false
        metadataTextField.maximumNumberOfLines = 2
        metadataTextField.font = .systemFont(ofSize: isPreview ? 12 : 18, weight: .medium)
        metadataTextField.textColor = .white

        NSLayoutConstraint.activate([
            metadataContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            metadataContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            metadataContainer.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
        ])

        NSLayoutConstraint.activate([
            metadataTextField.bottomAnchor.constraint(equalTo: metadataContainer.bottomAnchor, constant: -8),
            metadataTextField.topAnchor.constraint(equalTo: metadataContainer.topAnchor, constant: 8),
            metadataTextField.leadingAnchor.constraint(equalTo: metadataContainer.leadingAnchor, constant: 8),
            metadataTextField.trailingAnchor.constraint(equalTo: metadataContainer.trailingAnchor, constant: -8),
        ])

        metadataTextField.sizeToFit()

        run()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var hasConfigureSheet: Bool {
        return true
    }

    override var configureSheet: NSWindow? {
        return configurationController.window
    }

    override func startAnimation() {
        super.startAnimation()
    }

    override func stopAnimation() {
        super.stopAnimation()
    }

    private func run() {
        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(self,
                                       selector: #selector(OutsideView.playerItemDidPlayToEndTime(_:)),
                                       name: .AVPlayerItemDidPlayToEndTime,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(OutsideView.playerItemFailedToPlayToEndTime(_:)),
                                       name: .AVPlayerItemFailedToPlayToEndTime,
                                       object: nil)

        next()
    }

    func next() {
        guard
            let item = playlist.next(randomised: preferences.randomisePlayback)
        else {
            print("no next item, dunno want to do, bailing")
            return
        }

        metadataTextField.stringValue = ""
        metadataContainer.isHidden = true

        vimeo.fetchPlaybackURL(of: item.vimeoId) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self.play(item: item, url: url)
                }
            case .failure(let error):
                print("error: \(error)")
                self.next()
            }
        }
    }

    private func play(item: PlaybackItem, url: URL) {
        let playerItem = AVPlayerItem(url: url)

        let shadow = NSShadow()
        shadow.shadowBlurRadius = 0
        shadow.shadowColor = .black
        shadow.shadowOffset = .init(width: 1, height: 1)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 24, weight: .medium),
            .foregroundColor: NSColor.white,
        ]

        let shadowedAttributes: [NSAttributedString.Key: Any] = [
            .shadow: shadow,
        ].merging(attributes) { (_, new) in new }

        let metadata = NSMutableAttributedString()
        metadata.append(NSAttributedString(string: "📍\t", attributes: attributes))
        metadata.append(NSAttributedString(string: item.location, attributes: shadowedAttributes))
        metadata.append(NSAttributedString(string: "\n📸\t"))
        metadata.append(NSAttributedString(string: item.author, attributes: shadowedAttributes))

        metadataTextField.attributedStringValue = metadata
        metadataContainer.isHidden = false
        metadataContainer.alphaValue = 1

        metadataVisibleTimer?.invalidate()
        metadataVisibleTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] timer in
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                self?.metadataContainer.alphaValue = 0
            }
        }

        player.replaceCurrentItem(with: playerItem)
        player.actionAtItemEnd = .none
        player.play()
    }

    @objc
    func playerItemDidPlayToEndTime(_ notification: NSNotification) {
        next()
    }

    @objc
    func playerItemFailedToPlayToEndTime(_ notification: NSNotification) {
        next()
    }
}
