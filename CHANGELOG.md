# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [v2.0.0] - 2024-07-02Z

### Fixed

- Changed method to find stream URLs

### Changed

- Bumped minimum version to macOS 13
- Changed callbacks to async/await

## [v1.2.0] - 2024-04-11Z

### Fixed

- Updated API handler to account for occasionally missing keys.

## [v1.1.0] - 2024-02-15Z

### Changed

- Added a Sonoma-specific handler to kill the screensaver when after hiding. Sonoma will otherwise keep it running, which eats resources needlessly.

## [v1.0.0] - 2023-10-06Z

### Changed

- Use HTTP Live Streaming by default, instead of accessing videos directly
- Update `videos.json` schema (now: `videos.v2.json`), to clean up some old cruft

## [v0.3.0] - 2022-03-09Z

### Added

- Build with Apple silicon support

### Changed

- Metadata window stays visible constantly, but changes position at the start of a new video

## [v0.2.0] - 2021-10-30

### Added

- Generic mechanism for updating query parameters via JSON

## [v0.1.0] - 2021-01-05

### Added

- Fetch (and cache) latest manifest from GitHub

## [v0.0.5] - 2021-01-05

### Changed

- Bumped `videos.json`

## [v0.0.4] - 2021-01-02

### Added

- Included a script to fetch/update latest `videos.json` content

### Changed

- Updated `videos.json` to include timestamp
- Using `NSVisualEffectView` for background of metadata view

### Fixed

- Smaller font size in preview applied to attributed strings

## [v0.0.3] - 2021-01-01

### Changed

- Bumped `videos.json`

## [v0.0.2] - 2020-12-22

### Added

- Thumbnail for preference pane preview

## [v0.0.1] - 2020-12-22

### Added

- Import items from JSON
- Fetch stream URL from Vimeo
- Animate between videos
- Fastlane deloyment
- Preference: maximum stream quality
- Preference: mute audio
- Preference: randomise playback order
