# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fastlane/plugin/fastlane_screen_saver/version"

Gem::Specification.new do |spec|
  spec.name = "fastlane-plugin-fastlane_screen_saver"
  spec.version = Fastlane::FastlaneScreenSaver::VERSION
  spec.author = "Joshua May"

  spec.summary = "Parallel commands from fastlane for `.app` files, but for `.saver` instead."
  spec.license = "MIT"

  spec.files = Dir["lib/**/*"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "plist"
end
