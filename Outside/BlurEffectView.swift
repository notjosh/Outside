import AppKit

// this subclass is to (try to) control the blur effect, and reduce it to something a little less blurry
// it'll try to find the blur sublayer, or just bail and stick to defaults if it can't find it
class BlurEffectView: NSVisualEffectView {
    private let BlurRadius = 5

    override func updateLayer() {
        super.updateLayer()

        guard
            let layer = layer,
            let backdrop = findBackdrop(in: layer),
            let filters = backdrop.filters as [AnyObject]?
        else {
            return
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        // these are probably/hopefully `CAFilter`s, which is a private class, so we can't cast it directly
        // they have a bit of (iOS) documentation here: https://iphonedevwiki.net/index.php/CAFilter
        // all we're interested in is reducing the blur though, via `inputRadius`
        for filter in filters {
            guard
                let name = filter.value(forKey: "name") as? String,
                name.lowercased().contains("blur")
            else {
                continue
            }

            filter.setValue(BlurRadius, forKey: "inputRadius")
        }

        CATransaction.commit()
    }

    private func findBackdrop(in layer: CALayer) -> CALayer? {
        for sublayer in (layer.sublayers ?? []) {
            if let name = sublayer.name,
               name.lowercased() == "backdrop" {
                return sublayer
            }

            return findBackdrop(in: sublayer)
        }

        return nil
    }
}
