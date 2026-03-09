import 'package:flutter/material.dart';

import '../models/media_models.dart';

class DemoCatalog {
  const DemoCatalog._();

  static const hero = MediaItem(
    title: 'Eclipse Protocol',
    tagline: 'AI-curated sci-fi thriller with Dolby Vision layers and intro skipping baked in.',
    year: 2026,
    duration: '2h 14m',
    rating: 9.1,
    type: ContentType.movie,
    genres: ['Sci-Fi', 'Mystery', 'Thriller'],
    palette: [Color(0xFF8A5CFF), Color(0xFF08D9D6)],
    hasDolbyVision: true,
    hasHdr: true,
    skipIntroReady: true,
  );

  static const continueWatching = [
    MediaItem(
      title: 'Neon Shogun',
      tagline: 'Episode 7 • 38m left',
      year: 2025,
      duration: '48m',
      rating: 8.8,
      type: ContentType.anime,
      genres: ['Cyberpunk', 'Anime'],
      palette: [Color(0xFFFF7A18), Color(0xFFFF3C83)],
      progress: 0.42,
      skipIntroReady: true,
    ),
    MediaItem(
      title: 'Arcadia Prime',
      tagline: 'S2:E4 • synced via FlixNest Continue Watching',
      year: 2026,
      duration: '54m',
      rating: 8.9,
      type: ContentType.series,
      genres: ['Adventure', 'Drama'],
      palette: [Color(0xFF00B4DB), Color(0xFF0083B0)],
      progress: 0.68,
      hasHdr: true,
    ),
    MediaItem(
      title: 'Blue Ember',
      tagline: 'Movie • offline copy on device',
      year: 2024,
      duration: '1h 46m',
      rating: 8.4,
      type: ContentType.movie,
      genres: ['Action', 'Drama'],
      palette: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
      progress: 0.13,
    ),
  ];

  static const spotlight = [
    MediaItem(
      title: 'Signal Zero',
      tagline: 'Smart fallback streaming across multiple catalogs.',
      year: 2026,
      duration: '1h 58m',
      rating: 8.7,
      type: ContentType.movie,
      genres: ['Thriller', 'Drama'],
      palette: [Color(0xFF654EA3), Color(0xFFEAafc8)],
      hasHdr: true,
    ),
    MediaItem(
      title: 'Velvet Comet',
      tagline: 'Embedded trailers, sharper posters, and richer metadata.',
      year: 2026,
      duration: '10 ep',
      rating: 9.0,
      type: ContentType.series,
      genres: ['Fantasy', 'Adventure'],
      palette: [Color(0xFFFC5C7D), Color(0xFF6A82FB)],
      hasDolbyVision: true,
    ),
    MediaItem(
      title: 'Mirai Circuit',
      tagline: 'Anime sync ready for MAL and Kitsu workflows.',
      year: 2025,
      duration: '24 ep',
      rating: 8.6,
      type: ContentType.anime,
      genres: ['Anime', 'Racing'],
      palette: [Color(0xFF11998E), Color(0xFF38EF7D)],
      skipIntroReady: true,
    ),
    MediaItem(
      title: 'Last Horizon',
      tagline: 'Big-screen TV friendly layout with adaptive controls.',
      year: 2026,
      duration: '2h 07m',
      rating: 8.5,
      type: ContentType.movie,
      genres: ['Epic', 'Adventure'],
      palette: [Color(0xFF283048), Color(0xFF859398)],
      hasHdr: true,
    ),
  ];

  static const addons = [
    AddonSource(
      name: 'Meta Fusion+',
      kind: 'Metadata catalog',
      catalogs: 5,
      health: '99.2% healthy',
      priority: 1,
      pushReady: true,
    ),
    AddonSource(
      name: 'Torrent Pulse',
      kind: 'Streaming source',
      catalogs: 3,
      health: 'Fallback chain active',
      priority: 2,
      pushReady: true,
    ),
    AddonSource(
      name: 'Anime Atlas',
      kind: 'Anime feed',
      catalogs: 4,
      health: 'MAL/Kitsu paired',
      priority: 3,
    ),
    AddonSource(
      name: 'Retro Vault',
      kind: 'Curated library',
      catalogs: 2,
      health: 'Disabled on TV push',
      priority: 4,
      enabled: false,
    ),
  ];

  static const profiles = [
    UserProfile(
      name: 'Alex',
      accent: Color(0xFF7C5CFF),
      continueWatching: 12,
      parentalLevel: '16+',
    ),
    UserProfile(
      name: 'Luna',
      accent: Color(0xFF08D9D6),
      continueWatching: 5,
      parentalLevel: 'All ages',
    ),
    UserProfile(
      name: 'Guest TV',
      accent: Color(0xFFFF7A18),
      continueWatching: 3,
      parentalLevel: '13+',
    ),
  ];

  static const downloads = [
    DownloadTask(
      title: 'Arcadia Prime - S02E05',
      status: 'Queued into season folder',
      progress: 0.81,
      storage: '2.4 GB / TV cache',
    ),
    DownloadTask(
      title: 'Neon Shogun - Batch 01',
      status: 'Bulk anime sync in progress',
      progress: 0.53,
      storage: '6.1 GB / Offline vault',
    ),
    DownloadTask(
      title: 'Blue Ember',
      status: 'Ready for travel mode',
      progress: 1,
      storage: '1.7 GB / Downloaded',
    ),
  ];
}
