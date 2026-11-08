# daily

Daily Catholic prayer in ecclesiastical Latin, with English beneath.
Black background. White monospace. Morning, rosary, evening.

Planned: offline narration and synchronized scrolling at adjustable speed.
Currently: SwiftUI home screen and repository scaffold.

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

