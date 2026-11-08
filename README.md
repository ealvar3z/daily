# daily

Daily Catholic prayer in ecclesiastical Latin, with English beneath.
Black background. White monospace. Morning, rosary, evening.

Morning: Latin/English reader with adjustable automatic passage scrolling.
Tap a passage to select it; scroll to pause; resume to follow again.
Tap `latin first` or `english first` to swap languages; the choice is saved.
Your place and speed are saved. Reading pauses when the app leaves the screen.
Narration, rosary, and evening sessions are next. No audio is bundled yet.

## Run

On macOS with Xcode and XcodeGen:

```sh
brew install xcodegen
xcodegen generate
open daily.xcodeproj
```

Select the `daily` scheme and an iPhone simulator. For a device, choose your
signing team and a unique bundle identifier in Xcode.

`Daily/` contains the app; `project.yml` defines the generated Xcode project.
Codex guidance lives in `AGENTS.md` and `.agents/skills/ios-dev/SKILL.md`.

