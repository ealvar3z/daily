# daily

Build a small, native, offline iPhone prayer app. Read
`.agents/skills/ios-dev/SKILL.md` for iOS work.

## Product

- Three sessions: morning, today's rosary, evening.
- Ecclesiastical Latin first; paired English translation underneath.
- Black background, white EB Garamond text, square controls, lowercase `daily`.
- Use `AppFont` for scalable typography. Bundle fonts and their OFL license.
- Keep the approved monospaced app icon unchanged.
- Listen, read silently, or both; one speed setting controls playback and
  automatic scrolling. Preserve pitch and resume position.
- Bundle reviewed audio and text. No runtime AI, accounts, or backend.
- Do not add analytics.
- Daily reading: four reference rows (OT, NT, Ps, Prv), below evening.
  Bundle the approved original NRSV plan with the full Apocrypha. Use Gregorian
  month/day in the local time zone; February 29 is a catch-up day. Refresh on
  foregrounding and clock changes. Readers use their own physical Bible.
  Preserve provenance and special reading notes; do not substitute another
  edition's numbering or imply Tyndale authorship.
- Use the local date for mysteries: Mon/Sat joyful, Tue/Fri sorrowful,
  Wed/Sun glorious, Thu luminous. Freeze selection during a session.
- Morning: Sign of the Cross; acts of faith, hope, charity; Our Father;
  Hail Mary; Glory Be; Guardian Angel; Sign of the Cross.
- Evening: Sign of the Cross; thanksgiving/examination interval; act of
  contrition; Our Father; Hail Mary; Glory Be; Salve Regina; Eternal Rest;
  Sign of the Cross. These are devotions, not the Divine Office.
- Record sources and translation provenance with prayer content. Review
  ecclesiastical pronunciation before shipping; identify synthetic narration.

## Engineering

- Use SwiftUI and Apple frameworks. Add dependencies only for a concrete need.
- Keep views, prayer data, and playback separate. Avoid needless abstractions.
- Edit `project.yml`; regenerate the ignored Xcode project with XcodeGen.
- Keep prose within 80 columns. Keep documentation short and current.
- Test date selection, sequencing, and playback transitions when implemented.
- Check VoiceOver, Dynamic Type, Reduce Motion, interruption, and lock-screen
  playback when affected. Never claim simulator checks on a non-Apple host.
- Never commit credentials, signing material, or generated build products.
- Report what changed, what was checked, and any unverified behavior.

