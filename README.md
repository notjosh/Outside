# Outside

A screensaver for seeing outside, into the Real World™

The file `videos.json` drives the playlist, which can be updated to consume other videos.

It's soothing though, so that's neat.

## Tasks

### Update `videos.json`

```sh
# first time: cd ./scripts/update-json && yarn
node ./scripts/update-json/index.js ./Outside/videos.json
```

## Credits

- Original inspiration: [WindowSwap](https://window-swap.com/)
- Screen saver template: [ScreenSaverMinimal](https://github.com/glouel/ScreenSaverMinimal)
- Thumbnail icon: [Window View](https://flic.kr/p/fhwBVB)

## TODO

- [ ] OTA updates to `videos.json`
- [ ] option to deactivate when on battery/low battery
- [ ] video caching (via `AVAssetResourceLoader` and `AVURLAsset`)
- [ ] shortcut to skip to next video
- [ ] handle "offline" use case
- [ ] configure metadata corner
- [ ] configure metadata timeout
