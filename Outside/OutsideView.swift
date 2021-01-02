import AVKit
import AVFoundation
import ScreenSaver

let metadataTimeout: TimeInterval = 3

enum KeyCode: UInt16 {
    case space = 0x31
    case rightArrow = 0x7c
}

final class OutsideView: ScreenSaverView, ScreenSaverInterface {
    lazy var configurationController = ConfigurationController()

    let playlist = Playlist()
    let vimeo = Vimeo()
    let preferences = Preferences.shared

    let player: AVPlayer
    let playerLayer: AVPlayerLayer

    let metadataContainer: NSVisualEffectView
    let metadataTextField: NSTextField
    let progressIndicator: NSProgressIndicator

    var metadataVisibleTimer: Timer?
    var metadata: (PlaybackItem, VimeoConfigurationVideo)?

    deinit {
        playerLayer.removeObserver(self, forKeyPath: "readyForDisplay")

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

        metadataContainer = BlurEffectView(frame: .zero)
        metadataTextField = NSTextField(labelWithString: "")
        progressIndicator = NSProgressIndicator(frame: .zero)

        super.init(frame: frame, isPreview: preview)!

        wantsLayer = true

        playerLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        playerLayer.drawsAsynchronously = true
        playerLayer.frame = bounds
        playerLayer.opacity = 1
        playerLayer.videoGravity = .resizeAspectFill

        layer?.backgroundColor = NSColor.black.cgColor
        layer?.frame = bounds

        layer?.addSublayer(playerLayer)

        player.allowsExternalPlayback = false
        player.isMuted = preferences.muteAudio

        addSubview(metadataContainer)
        addSubview(progressIndicator)
        metadataContainer.addSubview(metadataTextField)

        metadataContainer.translatesAutoresizingMaskIntoConstraints = false
        metadataContainer.wantsLayer = true
        metadataContainer.layer?.cornerRadius = 5
        metadataContainer.appearance = NSAppearance(named: .vibrantDark)
        metadataContainer.blendingMode = .withinWindow
        metadataContainer.material = .fullScreenUI
        metadataContainer.state = .active

        metadataTextField.translatesAutoresizingMaskIntoConstraints = false
        metadataTextField.maximumNumberOfLines = 2
        metadataTextField.font = .systemFont(ofSize: preview ? 12 : 18, weight: .medium)
        metadataTextField.textColor = .white

        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        progressIndicator.isIndeterminate = true
        if #available(OSX 11.0, *) {
            progressIndicator.controlSize = .large
        }
        progressIndicator.appearance = NSAppearance(named: .vibrantLight)
        progressIndicator.style = .spinning

        NSLayoutConstraint.activate([
            progressIndicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            metadataContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),

            metadataContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            metadataContainer.trailingAnchor.constraint(lessThanOrEqualTo: progressIndicator.leadingAnchor, constant: -20),
            progressIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

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
        window?.acceptsMouseMovedEvents = true

        super.startAnimation()
    }

    override func stopAnimation() {
        super.stopAnimation()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard
            let keyPath = keyPath,
            keyPath == "readyForDisplay"
        else {
            return
        }

        if playerLayer.isReadyForDisplay {
            configureFadeInOut()
            player.play()

            hideLoading()
        }

        // buffering, show loading
        if player.timeControlStatus == .playing {
            if playerLayer.isReadyForDisplay {
                hideLoading()
            } else {
                showLoading()
            }
        }
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    override func keyDown(with event: NSEvent) {
        if preferences.useNextVideoShortcut,
           let keyCode = KeyCode(rawValue: event.keyCode) {
            if keyCode == .rightArrow {
                next()
                return
            }
        }

        super.keyDown(with: event)
    }

    override func mouseEntered(with event: NSEvent) {
        guard preferences.showMetadataOnMouseMove else {
            super.mouseEntered(with: event)
            return
        }

        // no-op
    }

    override func mouseExited(with event: NSEvent) {
        guard preferences.showMetadataOnMouseMove else {
            super.mouseExited(with: event)
            return
        }

        // no-op
    }

    override func mouseMoved(with event: NSEvent) {
        guard preferences.showMetadataOnMouseMove else {
            super.mouseMoved(with: event)
            return
        }

        showMetadata()
    }

    private func configureFadeInOut() {
        guard let video = metadata?.1 else {
            return
        }

        playerLayer.opacity = 0

        let duration: Double = 0.5
        let playbackDuration: Double = Double(max(0, video.duration - 1))

        playerLayer.removeAnimation(forKey: "fade")

        let fade = CAKeyframeAnimation(keyPath: "opacity")
        fade.values = [0, 1, 1, 0] as [Int]
        fade.keyTimes = [0, duration / playbackDuration, 1 - (duration / playbackDuration), 1] as [NSNumber]
        fade.duration = playbackDuration
        fade.calculationMode = .linear
        fade.delegate = self
        playerLayer.add(fade, forKey: "fade")

        showMetadata()
    }

    private func showMetadata() {
        metadataContainer.isHidden = false
        metadataContainer.alphaValue = 1

        metadataVisibleTimer?.invalidate()
        metadataVisibleTimer = nil
        metadataVisibleTimer = Timer.scheduledTimer(withTimeInterval: metadataTimeout, repeats: false) { [weak self] timer in
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                self?.metadataContainer.alphaValue = 0
            }
        }
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

        layer!.contentsScale = window?.backingScaleFactor ?? 1.0
        playerLayer.contentsScale = window?.backingScaleFactor ?? 1.0

        playerLayer.addObserver(self, forKeyPath: "readyForDisplay", options: .new, context: nil)

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
        showLoading()

        player.pause()
        playerLayer.removeAllAnimations()
        playerLayer.isHidden = true
        playerLayer.opacity = 0

        vimeo.fetchPlaybackURL(of: item.vimeoId, maximumHeight: preferences.highestQuality.rawValue) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success(let metadata):
                DispatchQueue.main.async {
                    self.metadata = (item, metadata.1)
                    self.play(item: item, url: metadata.0)
                }
            case .failure(let error):
                let error = error as NSError

                if error.code == -999 {
                    // the request was cancelled, so ignore the error
                    return
                }
                
                print("error: \(error)")
                DispatchQueue.main.async {
                    self.next()
                }
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

        showMetadata()

        player.replaceCurrentItem(with: playerItem)
        player.actionAtItemEnd = .none
        player.play()

        playerLayer.isHidden = false
    }

    @objc
    func playerItemDidPlayToEndTime(_ notification: NSNotification) {
        next()
    }

    @objc
    func playerItemFailedToPlayToEndTime(_ notification: NSNotification) {
        next()
    }

    func showLoading() {
        progressIndicator.startAnimation(self)
        progressIndicator.isHidden = false
    }

    func hideLoading() {
        progressIndicator.stopAnimation(self)
        progressIndicator.isHidden = true
    }
}

extension OutsideView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag == false {
            return
        }

        // the video might have paused to buffer, so instead of waiting for it to complete, we should proceed
        player.pause()
        next()
        print("animation ended, jumping to next", anim, flag)
    }
}
