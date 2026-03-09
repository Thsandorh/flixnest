import 'package:flutter/material.dart';

enum ContentType { movie, series, anime, liveEvent }

enum PlaybackEngine { auto, exoPlayer, mpv }

enum DecoderMode { auto, hardware, hybrid }

enum RendererMode { gpu, gpuNext }

enum AspectRatioMode { fit, fill, cinemaCrop, stretch }

class MediaItem {
  const MediaItem({
    required this.title,
    required this.tagline,
    required this.year,
    required this.duration,
    required this.rating,
    required this.type,
    required this.genres,
    required this.palette,
    this.progress = 0,
    this.hasDolbyVision = false,
    this.hasHdr = false,
    this.skipIntroReady = false,
  });

  final String title;
  final String tagline;
  final int year;
  final String duration;
  final double rating;
  final ContentType type;
  final List<String> genres;
  final List<Color> palette;
  final double progress;
  final bool hasDolbyVision;
  final bool hasHdr;
  final bool skipIntroReady;
}

class AddonSource {
  const AddonSource({
    required this.name,
    required this.kind,
    required this.catalogs,
    required this.health,
    required this.priority,
    this.enabled = true,
    this.pushReady = false,
  });

  final String name;
  final String kind;
  final int catalogs;
  final String health;
  final int priority;
  final bool enabled;
  final bool pushReady;
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.accent,
    required this.continueWatching,
    required this.parentalLevel,
  });

  final String name;
  final Color accent;
  final int continueWatching;
  final String parentalLevel;
}

class DownloadTask {
  const DownloadTask({
    required this.title,
    required this.status,
    required this.progress,
    required this.storage,
  });

  final String title;
  final String status;
  final double progress;
  final String storage;
}
