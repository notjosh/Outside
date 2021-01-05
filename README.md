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

### Release new build

```sh
agvtool new-marketing-version [version]
bundle exec fastlane release
```

## Credits

- Original inspiration: [WindowSwap](https://window-swap.com/)
- Screen saver template: [ScreenSaverMinimal](https://github.com/glouel/ScreenSaverMinimal)
- Thumbnail icon: [Window View](https://flic.kr/p/fhwBVB)

## TODO

- [x] OTA updates to `videos.json`
- [ ] option to deactivate when on battery/low battery
- [ ] video caching (via `AVAssetResourceLoader` and `AVURLAsset`)
- [ ] ~~shortcut to skip to next video~~ not possible as of 10.15 ([link](https://github.com/JohnCoates/Aerial/issues/1117#issuecomment-708282933))
- [ ] handle "offline" use case
- [ ] configure metadata corner
- [ ] configure metadata timeout
