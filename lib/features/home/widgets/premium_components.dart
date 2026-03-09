import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../app/flixnest_theme.dart';
import '../../../core/models/media_models.dart';
import '../../../core/services/network_probe_service.dart';

class FrostPanel extends StatelessWidget {
  const FrostPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 28,
    this.gradient,
    this.background,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Gradient? gradient;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final panelColor = gradient == null
        ? (background ?? Colors.white.withOpacity(0.05))
        : (background ?? Colors.transparent);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            gradient: gradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 40,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class GradientBadge extends StatelessWidget {
  const GradientBadge({super.key, required this.label, this.highlight = false});

  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        gradient: highlight
            ? const LinearGradient(colors: [FlixNestTheme.violet, FlixNestTheme.cyan])
            : LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.04),
                ],
              ),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: FlixNestTheme.violet.withOpacity(0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: highlight ? FlixNestTheme.canvas : Colors.white,
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.eyebrow, required this.title, required this.subtitle});

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: theme.textTheme.bodyMedium?.copyWith(
            letterSpacing: 1.8,
            fontWeight: FontWeight.w800,
            color: FlixNestTheme.cyan,
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(subtitle, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class PremiumButtonRow extends StatelessWidget {
  const PremiumButtonRow({super.key, required this.primaryLabel, required this.secondaryLabel, required this.tertiaryLabel});

  final String primaryLabel;
  final String secondaryLabel;
  final String tertiaryLabel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.play_arrow_rounded), label: Text(primaryLabel)),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_rounded), label: Text(secondaryLabel)),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.cast_connected_rounded), label: Text(tertiaryLabel)),
      ],
    );
  }
}

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key, required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item.palette.first,
            item.palette.last,
            const Color(0xFF09111C),
          ],
          stops: const [0, 0.58, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: item.palette.first.withOpacity(0.32),
            blurRadius: 60,
            offset: const Offset(0, 26),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      FlixNestTheme.canvas.withOpacity(0.35),
                      FlixNestTheme.canvas.withOpacity(0.82),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -60,
              top: -40,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(FlixNestSpace.hero),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 900;
                  final primary = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          GradientBadge(label: item.type.name.toUpperCase(), highlight: true),
                          if (item.hasDolbyVision) const GradientBadge(label: 'DOLBY VISION'),
                          if (item.hasHdr) const GradientBadge(label: 'HDR10+'),
                          if (item.skipIntroReady) const GradientBadge(label: 'SKIP INTRO READY'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(item.title, style: theme.textTheme.headlineLarge),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 560,
                        child: Text(item.tagline, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(0.9))),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          GradientBadge(label: '${item.rating.toStringAsFixed(1)} IMDB'),
                          GradientBadge(label: '${item.year} • ${item.duration}'),
                          ...item.genres.take(3).map((genre) => GradientBadge(label: genre)),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const PremiumButtonRow(
                        primaryLabel: 'Play instantly',
                        secondaryLabel: 'Download offline',
                        tertiaryLabel: 'Push to TV',
                      ),
                    ],
                  );

                  final side = FrostPanel(
                    background: Colors.black.withOpacity(0.22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeading(
                          eyebrow: 'Playback intelligence',
                          title: 'Adaptive HDR-first routing',
                          subtitle: 'Auto mode favors ExoPlayer for DV/HDR titles, drops to MPV for edge codecs, and keeps subtitle + intro metadata in sync.',
                        ),
                        const SizedBox(height: 20),
                        ProgressBand(progress: 0.58, buffer: 0.84),
                        const SizedBox(height: 16),
                        _SnapshotRow(label: 'Renderer', value: 'GPU-next'),
                        const SizedBox(height: 10),
                        _SnapshotRow(label: 'Buffer health', value: 'Stable / 1.4x headroom'),
                        const SizedBox(height: 10),
                        _SnapshotRow(label: 'Quick action', value: 'Hold to accelerate quiet scenes'),
                      ],
                    ),
                  );

                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [primary, const SizedBox(height: 28), side],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: primary),
                      const SizedBox(width: 24),
                      Expanded(flex: 4, child: side),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressBand extends StatelessWidget {
  const ProgressBand({super.key, required this.progress, required this.buffer});

  final double progress;
  final double buffer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: Colors.white.withOpacity(0.10)),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: buffer.clamp(0.0, 1.0).toDouble(),
                  child: ColoredBox(color: Colors.white.withOpacity(0.24)),
                ),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0).toDouble(),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [FlixNestTheme.cyan, FlixNestTheme.violet, FlixNestTheme.pink]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('00:38:14', style: TextStyle(fontWeight: FontWeight.w700)),
            Text('01:06:08', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}

class MediaPosterCard extends StatelessWidget {
  const MediaPosterCard({super.key, required this.item, this.width = 260, this.emphasized = false});

  static const _defaultPosterProgress = 0.18;
  static const _defaultPosterBuffer = 0.52;
  static const _bufferOffset = 0.24;

  final MediaItem item;
  final double width;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final progress = _posterProgress(item.progress);
    final buffer = _posterBuffer(item.progress);
    final height = emphasized ? 360.0 : 300.0;
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              item.palette.first.withOpacity(0.94),
              item.palette.last.withOpacity(0.80),
              const Color(0xFF08101A),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: item.palette.first.withOpacity(0.20),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: height * 0.42,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 92,
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white.withOpacity(0.10),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    child: const Icon(Icons.play_circle_outline_rounded, size: 42, color: Colors.white),
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  GradientBadge(label: item.type.name.toUpperCase()),
                  if (item.hasHdr) const GradientBadge(label: 'HDR'),
                  if (item.skipIntroReady) const GradientBadge(label: 'INTRO'),
                ],
              ),
              const Spacer(),
              Text(item.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(item.tagline, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 14),
              ProgressBand(progress: progress, buffer: buffer),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(item.duration, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  const Icon(Icons.star_rounded, size: 16, color: FlixNestTheme.amber),
                  const SizedBox(width: 4),
                  Text(item.rating.toStringAsFixed(1)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _posterProgress(double rawProgress) {
    return rawProgress == 0 ? _defaultPosterProgress : rawProgress;
  }

  double _posterBuffer(double rawProgress) {
    if (rawProgress == 0) {
      return _defaultPosterBuffer;
    }

    return (rawProgress + _bufferOffset).clamp(0.0, 1.0).toDouble();
  }
}

class StatSpotlightCard extends StatelessWidget {
  const StatSpotlightCard({super.key, required this.icon, required this.title, required this.body, required this.highlight});

  final IconData icon;
  final String title;
  final String body;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    return FrostPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(colors: [FlixNestTheme.violet, FlixNestTheme.cyan]),
            ),
            child: Icon(icon, color: FlixNestTheme.canvas),
          ),
          const SizedBox(height: 18),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          GradientBadge(label: highlight, highlight: true),
        ],
      ),
    );
  }
}

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.profile,
    required this.heroEnabled,
    required this.onHeroChanged,
    required this.onProfileSelected,
  });

  final UserProfile profile;
  final bool heroEnabled;
  final ValueChanged<bool> onHeroChanged;
  final ValueChanged<int> onProfileSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shouldExpandSearch = constraints.maxWidth < FlixNestBreakpoints.contentSplit;
          final header = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FlixNest', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text('A cleaner, faster streaming control plane for mobile, TV, and desktop.', style: Theme.of(context).textTheme.bodyMedium),
            ],
          );
          final controls = Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: shouldExpandSearch ? constraints.maxWidth : 340,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search movies, series, anime, addons...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ),
                ),
              ),
              FilterChip(
                selected: heroEnabled,
                onSelected: onHeroChanged,
                label: const Text('Hero section'),
                avatar: const Icon(Icons.auto_awesome_rounded, size: 18),
              ),
              PopupMenuButton<int>(
                onSelected: onProfileSelected,
                itemBuilder: (context) => List.generate(
                  3,
                  (index) => PopupMenuItem<int>(value: index, child: Text(['Alex', 'Luna', 'Guest TV'][index])),
                ),
                child: FrostPanel(
                  radius: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  background: Colors.white.withOpacity(0.05),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 12, backgroundColor: profile.accent),
                      const SizedBox(width: 10),
                      Text(profile.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down_rounded),
                    ],
                  ),
                ),
              ),
            ],
          );

          if (shouldExpandSearch) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const SizedBox(height: 16),
                controls,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: header),
              const SizedBox(width: 16),
              Flexible(child: controls),
            ],
          );
        },
      ),
    );
  }
}

class SidebarNavigation extends StatelessWidget {
  const SidebarNavigation({super.key, required this.index, required this.onSelected});

  final int index;
  final ValueChanged<int> onSelected;

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.video_library_rounded, 'Library'),
    (Icons.extension_rounded, 'Addons'),
    (Icons.play_circle_rounded, 'Playback'),
    (Icons.settings_rounded, 'Control'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 144,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [FlixNestTheme.violet, FlixNestTheme.cyan]),
            ),
            child: const Icon(Icons.movie_creation_outlined, color: FlixNestTheme.canvas, size: 34),
          ),
          const SizedBox(height: 26),
          ...List.generate(_items.length, (i) {
            final item = _items[i];
            final selected = i == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSelected(i),
                borderRadius: BorderRadius.circular(22),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: selected ? const LinearGradient(colors: [Color(0xFF8B5CFF), Color(0xFF08D9D6)]) : null,
                    color: selected ? null : Colors.transparent,
                  ),
                  child: Column(
                    children: [
                      Icon(item.$1, color: selected ? FlixNestTheme.canvas : Colors.white),
                      const SizedBox(height: 8),
                      Text(item.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? FlixNestTheme.canvas : Colors.white)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class SettingLine extends StatelessWidget {
  const SettingLine({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
        const SizedBox(width: 12),
        Flexible(child: Text(value, textAlign: TextAlign.right, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white))),
      ],
    );
  }
}

class SettingToggleLine extends StatelessWidget {
  const SettingToggleLine({super.key, required this.title, required this.subtitle, required this.value, required this.onChanged});

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class EnumSelector<T extends Enum> extends StatelessWidget {
  const EnumSelector({super.key, required this.label, required this.value, required this.values, required this.onChanged});

  final String label;
  final T value;
  final List<T> values;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((item) {
            return ChoiceChip(
              label: Text(_formatEnumName(item.name)),
              selected: item == value,
              onSelected: (_) => onChanged(item),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile, required this.selected, required this.onTap});

  final UserProfile profile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: selected ? profile.accent : Colors.white.withOpacity(0.08)),
          gradient: selected
              ? LinearGradient(colors: [profile.accent.withOpacity(0.28), Colors.white.withOpacity(0.04)])
              : LinearGradient(colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 22, backgroundColor: profile.accent),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text('${profile.continueWatching} continue-watching items • ${profile.parentalLevel}', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle_rounded, color: FlixNestTheme.cyan),
          ],
        ),
      ),
    );
  }
}

class DownloadRowCard extends StatelessWidget {
  const DownloadRowCard({super.key, required this.task});

  final DownloadTask task;

  @override
  Widget build(BuildContext context) {
    return FrostPanel(
      radius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 6),
          Text(task.status, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          ProgressBand(progress: task.progress, buffer: task.progress),
          const SizedBox(height: 10),
          Text(task.storage),
        ],
      ),
    );
  }
}

class AddonCard extends StatefulWidget {
  const AddonCard({
    super.key,
    required this.addon,
    required this.autoFallback,
    required this.onRename,
    required this.onPush,
  });

  final AddonSource addon;
  final bool autoFallback;
  final VoidCallback onRename;
  final VoidCallback onPush;

  @override
  State<AddonCard> createState() => _AddonCardState();
}

class _AddonCardState extends State<AddonCard> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.addon.enabled;
  }

  @override
  Widget build(BuildContext context) {
    return FrostPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.addon.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(widget.addon.kind, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Switch(
                value: _enabled,
                onChanged: (value) => setState(() => _enabled = value),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              GradientBadge(label: '${widget.addon.catalogs} catalogs'),
              GradientBadge(label: 'Priority ${widget.addon.priority}'),
              GradientBadge(label: _enabled ? 'ENABLED' : 'DISABLED'),
              if (widget.addon.pushReady) const GradientBadge(label: 'TV PUSH', highlight: true),
              if (widget.autoFallback) const GradientBadge(label: 'FALLBACK READY'),
            ],
          ),
          const SizedBox(height: 16),
          Text(widget.addon.health),
          const SizedBox(height: 18),
          Row(
            children: [
              TextButton.icon(
                onPressed: widget.onRename,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Rename'),
              ),
              const Spacer(),
              if (widget.addon.pushReady)
                FilledButton.tonalIcon(
                  onPressed: widget.onPush,
                  icon: const Icon(Icons.cast_connected_rounded),
                  label: const Text('Push'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ServiceConnectionCard extends StatelessWidget {
  const ServiceConnectionCard({super.key, required this.name, required this.detail, required this.icon});

  final String name;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FrostPanel(
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(colors: [FlixNestTheme.violet, FlixNestTheme.cyan]),
            ),
            child: Icon(icon, color: FlixNestTheme.canvas),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(detail, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: FlixNestTheme.success),
        ],
      ),
    );
  }
}

class NetworkProbeCard extends StatelessWidget {
  const NetworkProbeCard({super.key, required this.result});

  final NetworkProbeResult result;

  @override
  Widget build(BuildContext context) {
    final color = result.success ? FlixNestTheme.success : FlixNestTheme.amber;
    return FrostPanel(
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(result.success ? Icons.check_circle_rounded : Icons.error_outline_rounded, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(result.uri.toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text('Status: ${result.statusCode ?? 'error'} • ${result.latency.inMilliseconds} ms'),
                const SizedBox(height: 4),
                Text(result.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        const SizedBox(width: 12),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

String _formatEnumName(String value) {
  return value.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}').trim().toUpperCase();
}
