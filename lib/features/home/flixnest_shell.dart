import 'package:flutter/material.dart';

import '../../core/data/demo_catalog.dart';
import '../../core/models/media_models.dart';
import '../../core/services/network_probe_service.dart';

class FlixNestShell extends StatefulWidget {
  const FlixNestShell({super.key});

  @override
  State<FlixNestShell> createState() => _FlixNestShellState();
}

class _FlixNestShellState extends State<FlixNestShell> {
  int _tabIndex = 0;
  int _selectedProfile = 0;
  PlaybackEngine _engine = PlaybackEngine.auto;
  DecoderMode _decoder = DecoderMode.hybrid;
  RendererMode _renderer = RendererMode.gpuNext;
  AspectRatioMode _aspect = AspectRatioMode.cinemaCrop;
  bool _pip = true;
  bool _subtitleShadow = true;
  bool _dohEnabled = true;
  bool _autoFallback = true;
  bool _heroEnabled = true;
  bool _probingNetwork = false;
  List<NetworkProbeResult> _networkResults = const [];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 1180;
    final body = _tabs[_tabIndex](context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF090B12), Color(0xFF0B1220), Color(0xFF090B12)],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (isWide) _buildRail(context),
              Expanded(
                child: Column(
                  children: [
                    _TopBar(
                      profile: DemoCatalog.profiles[_selectedProfile],
                      heroEnabled: _heroEnabled,
                      onHeroChanged: (value) => setState(() => _heroEnabled = value),
                      onProfileSelected: (index) => setState(() => _selectedProfile = index),
                    ),
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _tabIndex,
              onDestinationSelected: (value) => setState(() => _tabIndex = value),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.video_library_rounded), label: 'Library'),
                NavigationDestination(icon: Icon(Icons.extension_rounded), label: 'Addons'),
                NavigationDestination(icon: Icon(Icons.play_circle_rounded), label: 'Playback'),
                NavigationDestination(icon: Icon(Icons.tune_rounded), label: 'Control'),
              ],
            ),
    );
  }

  Widget _buildRail(BuildContext context) {
    return Container(
      width: 108,
      margin: const EdgeInsets.all(18),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: NavigationRail(
        backgroundColor: Colors.transparent,
        selectedIndex: _tabIndex,
        onDestinationSelected: (value) => setState(() => _tabIndex = value),
        useIndicator: true,
        labelType: NavigationRailLabelType.all,
        destinations: const [
          NavigationRailDestination(icon: Icon(Icons.home_rounded), label: Text('Home')),
          NavigationRailDestination(icon: Icon(Icons.video_library_rounded), label: Text('Library')),
          NavigationRailDestination(icon: Icon(Icons.extension_rounded), label: Text('Addons')),
          NavigationRailDestination(icon: Icon(Icons.play_circle_rounded), label: Text('Playback')),
          NavigationRailDestination(icon: Icon(Icons.tune_rounded), label: Text('Control')),
        ],
      ),
    );
  }

  List<Widget Function(BuildContext)> get _tabs => [
        _buildHomeTab,
        _buildLibraryTab,
        _buildAddonsTab,
        _buildPlaybackTab,
        _buildControlTab,
      ];

  Widget _buildHomeTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      children: [
        if (_heroEnabled) _HeroSection(item: DemoCatalog.hero),
        const SizedBox(height: 22),
        const _SectionTitle(title: 'Continue watching', subtitle: 'Synced progress across phone, TV, and desktop.'),
        const SizedBox(height: 14),
        SizedBox(
          height: 238,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: DemoCatalog.continueWatching.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) => _MediaCard.large(item: DemoCatalog.continueWatching[index]),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 920;
            final spotlightPanel = _GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    title: 'Smart catalog curation',
                    subtitle: 'Modern views with IMDB-rich metadata, trailers, and banner-first presentation.',
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: DemoCatalog.spotlight
                        .map((item) => SizedBox(width: 240, child: _MediaCard(item: item)))
                        .toList(),
                  ),
                ],
              ),
            );
            const sidePanels = Column(
              children: [
                _StatPanel(
                  title: 'Sync pulse',
                  lines: [
                    'Trakt watchlist imported into local library',
                    'MAL and Kitsu anime sync ready',
                    'Continue Watching checkpoints mirrored instantly',
                  ],
                  highlight: '12 active sync events',
                  icon: Icons.sync_rounded,
                ),
                SizedBox(height: 18),
                _StatPanel(
                  title: 'Parental guide',
                  lines: [
                    'Translated severity labels on detail pages',
                    'Profile-specific age gates and warnings',
                    'TV-safe browsing mode for shared rooms',
                  ],
                  highlight: '3 protected profiles',
                  icon: Icons.shield_rounded,
                ),
              ],
            );

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: spotlightPanel),
                  const SizedBox(width: 18),
                  Expanded(flex: 3, child: sidePanels),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                spotlightPanel,
                const SizedBox(height: 18),
                sidePanels,
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLibraryTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      children: [
        const _SectionTitle(
          title: 'Library orchestration',
          subtitle: 'Watchlists, offline vault, and profile-aware continue watching in one place.',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 920;
            final profilesPanel = _GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Profiles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  ...List.generate(DemoCatalog.profiles.length, (index) {
                    final profile = DemoCatalog.profiles[index];
                    final selected = index == _selectedProfile;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ProfileTile(
                        profile: profile,
                        selected: selected,
                        onTap: () => setState(() => _selectedProfile = index),
                      ),
                    );
                  }),
                ],
              ),
            );
            final downloadsPanel = _GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Offline downloads', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  ...DemoCatalog.downloads.map((task) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _DownloadTile(task: task),
                      )),
                ],
              ),
            );

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: profilesPanel),
                  const SizedBox(width: 18),
                  Expanded(flex: 2, child: downloadsPanel),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profilesPanel,
                const SizedBox(height: 18),
                downloadsPanel,
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddonsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      children: [
        const _SectionTitle(
          title: 'Addon ecosystem',
          subtitle: 'Install, reorder, rename, disable, and push catalogs across devices with fallback streaming logic.',
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: DemoCatalog.addons
              .map((addon) => SizedBox(
                    width: 340,
                    child: _AddonCard(
                      addon: addon,
                      autoFallback: _autoFallback,
                      onPush: () => _showMessage('${addon.name} pushed to the TV profile.'),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 18),
        _GlassPanel(
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Smart stream fallback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    Text(
                      'When the preferred source fails, FlixNest automatically proposes the next addon/stream candidate without dropping you out of the viewing flow.',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: _autoFallback,
                onChanged: (value) => setState(() => _autoFallback = value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackTab(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      children: [
        const _SectionTitle(
          title: 'Playback lab',
          subtitle: 'Dual engine playback, MPV tuning, PiP, subtitle control, aspect ratio presets, and external player launch points.',
        ),
        const SizedBox(height: 16),
        _GlassPanel(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 760;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (stacked)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DemoCatalog.hero.title, style: theme.textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text(
                          'Adaptive playback preview with visual buffer track, Dolby Vision/HDR badges, and hold-to-speed-up interaction designed for mobile and TV remotes alike.',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _showMessage('Launching ${_engine.name.toUpperCase()} playback preview.'),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Play now'),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DemoCatalog.hero.title, style: theme.textTheme.headlineMedium),
                              const SizedBox(height: 8),
                              Text(
                                'Adaptive playback preview with visual buffer track, Dolby Vision/HDR badges, and hold-to-speed-up interaction designed for mobile and TV remotes alike.',
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        FilledButton.icon(
                          onPressed: () => _showMessage('Launching ${_engine.name.toUpperCase()} playback preview.'),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Play now'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(colors: [Color(0xFF8A5CFF), Color(0xFF08D9D6)]),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 24,
                          top: 24,
                          child: Wrap(
                            spacing: 8,
                            children: const [
                              _Badge(label: 'Dolby Vision'),
                              _Badge(label: 'HDR'),
                              _Badge(label: 'IntroDB Ready'),
                            ],
                          ),
                        ),
                        const Positioned(
                          left: 24,
                          right: 24,
                          bottom: 28,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ProgressTrack(progress: 0.58, buffer: 0.81),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('00:38:14', style: TextStyle(fontWeight: FontWeight.w700)),
                                  Text('01:06:08', style: TextStyle(fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 960;
            return Wrap(
              spacing: 18,
              runSpacing: 18,
              children: [
                SizedBox(width: wide ? constraints.maxWidth * 0.46 : constraints.maxWidth, child: _enginePanel()),
                SizedBox(width: wide ? constraints.maxWidth * 0.46 : constraints.maxWidth, child: _subtitlePanel()),
                SizedBox(width: wide ? constraints.maxWidth * 0.46 : constraints.maxWidth, child: _externalPlayerPanel()),
                SizedBox(width: wide ? constraints.maxWidth * 0.46 : constraints.maxWidth, child: _introPanel()),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildControlTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      children: [
        const _SectionTitle(
          title: 'Control center',
          subtitle: 'Cross-service sync, DNS privacy, localization, and device intelligence settings.',
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: [
            SizedBox(
              width: 420,
              child: _GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Connected services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    const _ServiceTile(name: 'Trakt', detail: 'Watchlist import • Continue Watching sync', icon: Icons.movie_filter_rounded),
                    const SizedBox(height: 10),
                    const _ServiceTile(name: 'MyAnimeList', detail: 'Anime episode progress paired', icon: Icons.animation_rounded),
                    const SizedBox(height: 10),
                    const _ServiceTile(name: 'Kitsu', detail: 'Season-level anime tracking enabled', icon: Icons.auto_awesome_rounded),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 420,
              child: _GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Privacy & localization', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    _SettingToggle(
                      title: 'DNS-over-HTTPS',
                      subtitle: 'Hide DNS queries from the ISP on supported devices.',
                      value: _dohEnabled,
                      onChanged: (value) => setState(() => _dohEnabled = value),
                    ),
                    const Divider(height: 26),
                    const _SettingRow(title: 'Language pack', value: 'Hungarian • English • Japanese'),
                    const Divider(height: 26),
                    const _SettingRow(title: 'TV navigation mode', value: 'Optimized capsules and horizontal focus flow'),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 420,
              child: _GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Network diagnostics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text('Try outbound connectivity to a few safe public endpoints and surface the response health inside the app.'),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _probingNetwork ? null : _runNetworkProbe,
                      icon: Icon(_probingNetwork ? Icons.wifi_tethering_error_rounded : Icons.language_rounded),
                      label: Text(_probingNetwork ? 'Probing...' : 'Run network probe'),
                    ),
                    const SizedBox(height: 14),
                    if (_networkResults.isEmpty)
                      const Text('No probe results yet. Run the diagnostic to validate reachable endpoints.')
                    else
                      ..._networkResults.map((result) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _NetworkResultTile(result: result),
                          )),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 420,
              child: _GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Product goals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        _Badge(label: 'Faster UI'),
                        _Badge(label: 'Cleaner architecture'),
                        _Badge(label: 'TV-ready'),
                        _Badge(label: 'PiP-aware'),
                        _Badge(label: 'Offline-first'),
                        _Badge(label: 'Smart fallback'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'This source foundation is organized to make native playback engines, sync providers, and addon protocols pluggable without rewriting the shell UI.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _enginePanel() {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Engine tuning', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _EnumSelector<PlaybackEngine>(
            label: 'Playback engine',
            value: _engine,
            values: PlaybackEngine.values,
            onChanged: (value) => setState(() => _engine = value),
          ),
          const SizedBox(height: 12),
          _EnumSelector<DecoderMode>(
            label: 'Decoder mode',
            value: _decoder,
            values: DecoderMode.values,
            onChanged: (value) => setState(() => _decoder = value),
          ),
          const SizedBox(height: 12),
          _EnumSelector<RendererMode>(
            label: 'Renderer',
            value: _renderer,
            values: RendererMode.values,
            onChanged: (value) => setState(() => _renderer = value),
          ),
          const SizedBox(height: 12),
          _EnumSelector<AspectRatioMode>(
            label: 'Aspect ratio',
            value: _aspect,
            values: AspectRatioMode.values,
            onChanged: (value) => setState(() => _aspect = value),
          ),
          const SizedBox(height: 14),
          _SettingToggle(
            title: 'Picture-in-Picture',
            subtitle: 'Keep playback alive in the background when leaving the app.',
            value: _pip,
            onChanged: (value) => setState(() => _pip = value),
          ),
        ],
      ),
    );
  }

  Widget _subtitlePanel() {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Subtitles & gesture speed-up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          const _SettingRow(title: 'Subtitle source', value: 'Internal + external tracks merged'),
          const SizedBox(height: 10),
          const _SettingRow(title: 'Typography preset', value: 'High-contrast TV safe with pill background'),
          const SizedBox(height: 10),
          _SettingToggle(
            title: 'Text shadow',
            subtitle: 'Improve readability over HDR and bright scenes.',
            value: _subtitleShadow,
            onChanged: (value) => setState(() => _subtitleShadow = value),
          ),
          const Divider(height: 26),
          const Text(
            'Hold-to-boost playback is designed as a touch/remote aware action for skimming boring moments without fully changing your long-term speed preference.',
          ),
        ],
      ),
    );
  }

  Widget _externalPlayerPanel() {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('External players', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ActionChip(label: const Text('VLC'), onPressed: () => _showMessage('Sent stream to VLC.')),
              ActionChip(label: const Text('MX Player'), onPressed: () => _showMessage('Sent stream to MX Player.')),
              ActionChip(label: const Text('System chooser'), onPressed: () => _showMessage('Opened external player chooser.')),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Useful when a specific codec, subtitle style, or niche hardware path performs better outside the embedded engines.'),
        ],
      ),
    );
  }

  Widget _introPanel() {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('IntroDB workflow', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          const _SettingRow(title: 'Skip intro state', value: 'Auto-detected for 67% of followed series'),
          const SizedBox(height: 10),
          const _SettingRow(title: 'Community submit mode', value: 'One-tap timestamp capture UI ready'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _showMessage('Intro timestamp submission drafted.'),
            icon: const Icon(Icons.timer_rounded),
            label: const Text('Submit intro markers'),
          ),
        ],
      ),
    );
  }


  Future<void> _runNetworkProbe() async {
    setState(() => _probingNetwork = true);
    final results = await const NetworkProbeService().probeDefaults();
    if (!mounted) {
      return;
    }
    setState(() {
      _networkResults = results;
      _probingNetwork = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Wrap(
        runSpacing: 12,
        spacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FlixNest', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              const Text('Smarter streaming for phone, TV, and desktop.'),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 280,
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText: 'Search movies, series, anime, addons...',
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.mic_none_rounded),
                    ),
                  ),
                ),
              ),
              FilterChip(
                selected: heroEnabled,
                onSelected: onHeroChanged,
                avatar: const Icon(Icons.view_carousel_rounded, size: 18),
                label: const Text('Hero section'),
              ),
              PopupMenuButton<int>(
                tooltip: 'Choose profile',
                onSelected: onProfileSelected,
                itemBuilder: (context) => List.generate(
                  DemoCatalog.profiles.length,
                  (index) => PopupMenuItem<int>(
                    value: index,
                    child: Text(DemoCatalog.profiles[index].name),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
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
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(colors: item.palette),
        boxShadow: [
          BoxShadow(
            color: item.palette.first.withOpacity(0.35),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 840;
          final primary = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Badge(label: item.type.name.toUpperCase()),
                  if (item.hasDolbyVision) const _Badge(label: 'Dolby Vision'),
                  if (item.hasHdr) const _Badge(label: 'HDR'),
                  if (item.skipIntroReady) const _Badge(label: 'Skip Intro'),
                ],
              ),
              const SizedBox(height: 18),
              Text(item.title, style: theme.textTheme.headlineLarge),
              const SizedBox(height: 12),
              Text(item.tagline, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Continue watching'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () {},
                    icon: const Icon(Icons.send_to_mobile_rounded),
                    label: const Text('Push to TV'),
                  ),
                ],
              ),
            ],
          );
          final secondary = _GlassPanel(
            color: Colors.black.withOpacity(0.22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Playback snapshot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                const _SettingRow(title: 'Engine routing', value: 'Auto → ExoPlayer preferred for HDR/DV'),
                const SizedBox(height: 10),
                const _SettingRow(title: 'Subtitle stack', value: 'Embedded + external with custom styling'),
                const SizedBox(height: 10),
                const _SettingRow(title: 'Quick boost', value: 'Hold to speed up in quiet scenes'),
                const SizedBox(height: 16),
                const _ProgressTrack(progress: 0.32, buffer: 0.74),
              ],
            ),
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                primary,
                const SizedBox(height: 24),
                secondary,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: primary),
              const SizedBox(width: 24),
              Expanded(child: secondary),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(subtitle),
      ],
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }
}

class _MediaCard extends StatelessWidget {
  const _MediaCard({required this.item}) : large = false;
  const _MediaCard.large({required this.item}) : large = true;

  final MediaItem item;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: large ? 300 : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: item.palette),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(label: item.type.name),
              if (item.hasHdr) const _Badge(label: 'HDR'),
              if (item.skipIntroReady) const _Badge(label: 'Intro'),
            ],
          ),
          const Spacer(),
          Text(item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(item.tagline, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          _ProgressTrack(progress: item.progress, buffer: item.progress + ((1 - item.progress) * 0.4)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(item.duration),
              const Spacer(),
              const Icon(Icons.star_rounded, size: 18),
              const SizedBox(width: 4),
              Text(item.rating.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPanel extends StatelessWidget {
  const _StatPanel({
    required this.title,
    required this.lines,
    required this.highlight,
    required this.icon,
  });

  final String title;
  final List<String> lines;
  final String highlight;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ...lines.map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Icon(Icons.circle, size: 8),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(line)),
                  ],
                ),
              )),
          const SizedBox(height: 10),
          _Badge(label: highlight),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.profile, required this.selected, required this.onTap});

  final UserProfile profile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected ? profile.accent.withOpacity(0.18) : Colors.white.withOpacity(0.04),
          border: Border.all(
            color: selected ? profile.accent : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: profile.accent),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('${profile.continueWatching} continue watching items • ${profile.parentalLevel}'),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle_rounded),
          ],
        ),
      ),
    );
  }
}

class _DownloadTile extends StatelessWidget {
  const _DownloadTile({required this.task});

  final DownloadTask task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(task.status),
          const SizedBox(height: 12),
          _ProgressTrack(progress: task.progress, buffer: task.progress),
          const SizedBox(height: 8),
          Text(task.storage),
        ],
      ),
    );
  }
}

class _AddonCard extends StatelessWidget {
  const _AddonCard({required this.addon, required this.autoFallback, required this.onPush});

  final AddonSource addon;
  final bool autoFallback;
  final VoidCallback onPush;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(addon.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(addon.kind),
                  ],
                ),
              ),
              Switch(value: addon.enabled, onChanged: (_) {}),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(label: '${addon.catalogs} catalogs'),
              _Badge(label: 'Priority ${addon.priority}'),
              if (addon.pushReady) const _Badge(label: 'TV Push'),
              if (autoFallback) const _Badge(label: 'Fallback chain'),
            ],
          ),
          const SizedBox(height: 12),
          Text(addon.health),
          const SizedBox(height: 14),
          Row(
            children: [
              TextButton.icon(onPressed: () {}, icon: const Icon(Icons.edit_rounded), label: const Text('Rename')),
              const Spacer(),
              if (addon.pushReady)
                FilledButton.tonalIcon(
                  onPressed: onPush,
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

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.progress, required this.buffer});

  final double progress;
  final double buffer;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 8,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: Colors.white.withOpacity(0.18)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: buffer.clamp(0.0, 1.0).toDouble(),
              child: ColoredBox(color: Colors.white.withOpacity(0.34)),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0).toDouble(),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF08D9D6), Color(0xFF7C5CFF)]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
        const SizedBox(width: 16),
        Flexible(child: Text(value, textAlign: TextAlign.right)),
      ],
    );
  }
}

class _SettingToggle extends StatelessWidget {
  const _SettingToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

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
              const SizedBox(height: 4),
              Text(subtitle),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _EnumSelector<T extends Enum> extends StatelessWidget {
  const _EnumSelector({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

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
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values
              .map(
                (item) => ChoiceChip(
                  label: Text(_formatEnumName(item.name)),
                  selected: value == item,
                  onSelected: (_) => onChanged(item),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

String _formatEnumName(String value) {
  return value
      .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
      .trim()
      .toUpperCase();
}

class _NetworkResultTile extends StatelessWidget {
  const _NetworkResultTile({required this.result});

  final NetworkProbeResult result;

  @override
  Widget build(BuildContext context) {
    final tint = result.success ? const Color(0xFF08D9D6) : const Color(0xFFFF7A18);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(result.success ? Icons.check_circle_rounded : Icons.error_outline_rounded, color: tint),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(result.uri.toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('Status: ${result.statusCode ?? 'error'} • ${result.latency.inMilliseconds} ms'),
                const SizedBox(height: 4),
                Text(result.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.name, required this.detail, required this.icon});

  final String name;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(detail),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: Color(0xFF08D9D6)),
        ],
      ),
    );
  }
}
