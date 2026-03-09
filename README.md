# FlixNest

FlixNest is a Flutter-based streaming application foundation targeting Android phones, Android TV, and desktop form factors with a modern, high-density premium UI.

## What is included

- Adaptive shell for desktop and touch layouts
- Hero-driven home experience with smarter information density
- Playback control center with dual-engine concepts (Auto / ExoPlayer / MPV)
- Subtitle, PiP, aspect ratio, external player, and intro-skip UX surfaces
- Addon ecosystem management screen with fallback and TV-push concepts
- Sync, privacy, localization, parental-control, profile, and download dashboards
- Cleanly separated app/theme/model/data/shell structure for future native integrations

## Notes

This repository started empty, so the initial implementation focuses on delivering a substantial Flutter application source foundation with clean architecture and polished UI. Native playback engines, Trakt/MAL/Kitsu auth flows, torrent streaming, and actual Stremio/addon protocol integrations would need follow-up implementation against their respective APIs/SDKs.

## Intended commands

Once Flutter is available in the environment:

```bash
flutter pub get
flutter run
flutter test
flutter build apk
```
