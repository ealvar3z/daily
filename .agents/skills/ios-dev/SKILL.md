---
name: ios-dev
description: >-
  Develop and review the daily native iOS app. Use for SwiftUI screens,
  prayer models, AVFoundation playback, synchronized scrolling, accessibility,
  Xcode configuration, and iOS testing in this repository.
---

# iOS development

1. Read `AGENTS.md`, `project.yml`, and the affected sources. Check the working
   tree before editing. Preserve unrelated changes.
2. Confirm the available Xcode, Swift, SDK, and simulator versions. Consult
   Apple documentation for unfamiliar APIs and deployment availability.
3. Implement the smallest complete change. Use value types for prayer data
   and main-actor isolation for observable UI state. Keep file and audio
   preparation off the UI thread; avoid detached tasks without a clear need.
4. Update `project.yml` for target changes, then run `xcodegen generate`.
   Do not hand-edit the generated project or add a dependency manager.
5. Build on macOS using the command below. When tests exist, discover an
   available simulator with `xcodebuild -showdestinations`, then run the
   relevant tests using its destination ID. Report unavailable checks.

```sh
xcodebuild -project daily.xcodeproj -scheme daily \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO build
```

## Prayer and playback

- Give prayers, passages, and repeated session occurrences stable IDs.
- Pair Latin and English by passage; preserve punctuation and Unicode accents.
- Store vetted texts, source references, and audio cue times as bundled data.
- Drive audible scrolling from media time, never a separate repeating timer.
  Use the same cue timeline with a monotonic clock for silent reading.
- Preserve position across speed changes; preserve pitch. Pause automatic
  following on manual scrolling and provide an explicit resume control.
- Model play, pause, seek, interruption, completion, and restoration explicitly.
  Remove observers and cancel tasks when their owner is released.
- Add background audio configuration, audio-session handling, Now Playing,
  and remote commands together when implementing lock-screen playback.
- Treat narration models as production tools, not app dependencies. Keep API
  secrets out of the app. Verify every recorded prayer against its source.

## Verification

- Test behavior: local-date boundaries, all seven mystery selections, repeated
  decade ordering, cue selection, pause/resume, seeking, and speed changes.
- Check the affected flow on a simulator and audio routes on a real device.
- Keep text scalable, controls accessible, and Latin/English reading order
  intact. Respect Reduce Motion without losing the current passage.
- Summarize actual checks and remaining limitations. Do not add boilerplate
  tests, infrastructure, or documentation to make a small change look larger.

