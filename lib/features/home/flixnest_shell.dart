import 'package:flutter/material.dart';

import '../../core/data/demo_catalog.dart';
import '../../core/models/media_models.dart';
import '../../core/services/network_probe_service.dart';
import 'widgets/premium_components.dart';

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
    final isWide = MediaQuery.sizeOf(context).width >= 1200;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.3,
            colors: [Color(0xFF18233A), Color(0xFF0D1420), Color(0xFF0A0F17)],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (isWide)
                SidebarNavigation(
                  index: _tabIndex,
                  onSelected: (value) => setState(() => _tabIndex = value),
                ),
              Expanded(
                child: Column(
                  children: [
                    AppTopBar(
                      profile: DemoCatalog.profiles[_selectedProfile],
                      heroEnabled: _heroEnabled,
                      onHeroChanged: (value) => setState(() => _heroEnabled = value),
                      onProfileSelected: (index) => setState(() => _selectedProfile = index),
                    ),
                    Expanded(child: _buildBody()),
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
                NavigationDestination(icon: Icon(Icons.hub_rounded), label: 'Control'),
              ],
            ),
    );
  }

  Widget _buildBody() {
    switch (_tabIndex) {
      case 0:
        return _homeTab();
      case 1:
        return _libraryTab();
      case 2:
        return _addonsTab();
      case 3:
        return _playbackTab();
      case 4:
        return _controlTab();
      default:
        return _homeTab();
    }
  }

  Widget _homeTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
      children: [
        if (_heroEnabled) HeroBanner(item: DemoCatalog.hero),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 1080;
            final continueWatching = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading(
                  eyebrow: 'Continue watching',
                  title: 'Resume anywhere, instantly',
                  subtitle: 'Cross-device checkpoints, richer metadata, and cleaner poster-first browsing for mobile and TV.',
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 322,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: DemoCatalog.continueWatching.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 18),
                    itemBuilder: (context, index) => MediaPosterCard(
                      item: DemoCatalog.continueWatching[index],
                      emphasized: true,
                      width: 280,
                    ),
                  ),
                ),
              ],
            );

            final rightRail = Column(
              children: const [
                StatSpotlightCard(
                  icon: Icons.sync_alt_rounded,
                  title: 'Sync pulse',
                  body: 'Trakt watchlists, MAL/Kitsu anime progress, and Continue Watching checkpoints stay mirrored across device classes.',
                  highlight: '12 live sync events',
                ),
                SizedBox(height: 18),
                StatSpotlightCard(
                  icon: Icons.tv_rounded,
                  title: 'Living-room ready',
                  body: 'Larger focus targets, cleaner horizontal scanning, and TV-safe information density without wasting space.',
                  highlight: 'Android TV optimized',
                ),
              ],
            );

            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [continueWatching, const SizedBox(height: 18), rightRail],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 8, child: continueWatching),
                const SizedBox(width: 18),
                Expanded(flex: 4, child: rightRail),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        FrostPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading(
                eyebrow: 'Featured collections',
                title: 'Catalogs that feel cinematic, not cluttered',
                subtitle: 'Sharper visual hierarchy for trailers, metadata, banners, and smart content grouping.',
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 18,
                runSpacing: 18,
                children: DemoCatalog.spotlight
                    .map((item) => MediaPosterCard(item: item, width: 270))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _libraryTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
      children: [
        const SectionHeading(
          eyebrow: 'Profiles & offline',
          title: 'Personalized libraries with cleaner handoff',
          subtitle: 'Each profile keeps its own continue-watching lane, content filters, and parental labels.',
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 980;
            final profiles = FrostPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Profiles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  ...List.generate(DemoCatalog.profiles.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: ProfileCard(
                        profile: DemoCatalog.profiles[index],
                        selected: index == _selectedProfile,
                        onTap: () => setState(() => _selectedProfile = index),
                      ),
                    );
                  }),
                ],
              ),
            );

            final downloads = FrostPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Offline vault', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  ...DemoCatalog.downloads.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: DownloadRowCard(task: task),
                    ),
                  ),
                ],
              ),
            );

            if (!wide) {
              return Column(
                children: [profiles, const SizedBox(height: 18), downloads],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: profiles),
                const SizedBox(width: 18),
                Expanded(flex: 2, child: downloads),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _addonsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
      children: [
        const SectionHeading(
          eyebrow: 'Stremio ecosystem',
          title: 'Addon orchestration that feels intentional',
          subtitle: 'Install multiple catalogs, reorder source priority, and push the exact setup to Android TV.',
        ),
        const SizedBox(height: 20),
        FrostPanel(
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Fallback routing intelligently proposes the next best stream when a source fails, keeping the viewing flow alive instead of dumping the user back into selection.',
                ),
              ),
              const SizedBox(width: 18),
              Switch(
                value: _autoFallback,
                onChanged: (value) => setState(() => _autoFallback = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: DemoCatalog.addons
              .map(
                (addon) => SizedBox(
                  width: 360,
                  child: AddonCard(
                    addon: addon,
                    autoFallback: _autoFallback,
                    onPush: () => _showMessage('${addon.name} pushed to the TV profile.'),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _playbackTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
      children: [
        const SectionHeading(
          eyebrow: 'Playback lab',
          title: 'Sharper control over engines, subtitles, and output',
          subtitle: 'Designed for users who care about codec behavior, TV comfort, and fast recovery when streams fail.',
        ),
        const SizedBox(height: 20),
        FrostPanel(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0x448B5CFF),
              const Color(0x2208D9D6),
              Colors.white.withOpacity(0.02),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading(
                eyebrow: 'Now tuning',
                title: 'Eclipse Protocol · Premium playback session',
                subtitle: 'Visual buffer clarity, HDR routing, intro skipping, and quick external player handoff in one surface.',
              ),
              const SizedBox(height: 20),
              const ProgressBand(progress: 0.58, buffer: 0.81),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: [
            SizedBox(
              width: 480,
              child: FrostPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Engine selection', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 18),
                    EnumSelector<PlaybackEngine>(
                      label: 'Playback engine',
                      value: _engine,
                      values: PlaybackEngine.values,
                      onChanged: (value) => setState(() => _engine = value),
                    ),
                    const SizedBox(height: 18),
                    EnumSelector<DecoderMode>(
                      label: 'Decoder mode',
                      value: _decoder,
                      values: DecoderMode.values,
                      onChanged: (value) => setState(() => _decoder = value),
                    ),
                    const SizedBox(height: 18),
                    EnumSelector<RendererMode>(
                      label: 'Renderer',
                      value: _renderer,
                      values: RendererMode.values,
                      onChanged: (value) => setState(() => _renderer = value),
                    ),
                    const SizedBox(height: 18),
                    EnumSelector<AspectRatioMode>(
                      label: 'Aspect ratio',
                      value: _aspect,
                      values: AspectRatioMode.values,
                      onChanged: (value) => setState(() => _aspect = value),
                    ),
                    const SizedBox(height: 18),
                    SettingToggleLine(
                      title: 'Picture-in-Picture',
                      subtitle: 'Keep playback alive while browsing catalogs or leaving the app.',
                      value: _pip,
                      onChanged: (value) => setState(() => _pip = value),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 480,
              child: FrostPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Subtitle & playback actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 18),
                    const SettingLine(label: 'Subtitle merge', value: 'Internal + external tracks'),
                    const SizedBox(height: 14),
                    const SettingLine(label: 'Typography preset', value: 'High-contrast TV-safe capsules'),
                    const SizedBox(height: 14),
                    SettingToggleLine(
                      title: 'Text shadow',
                      subtitle: 'Improves readability in bright HDR scenes.',
                      value: _subtitleShadow,
                      onChanged: (value) => setState(() => _subtitleShadow = value),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ActionChip(label: const Text('VLC'), onPressed: () => _showMessage('Sent stream to VLC.')),
                        ActionChip(label: const Text('MX Player'), onPressed: () => _showMessage('Sent stream to MX Player.')),
                        ActionChip(label: const Text('System chooser'), onPressed: () => _showMessage('Opened external player chooser.')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SettingLine(label: 'IntroDB submit', value: 'One-tap timestamp drafting ready'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _controlTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
      children: [
        const SectionHeading(
          eyebrow: 'Control center',
          title: 'Sync, privacy, and diagnostics in one command deck',
          subtitle: 'Built to make cross-service setup, network health, and localization feel more intentional and less buried.',
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: [
            SizedBox(
              width: 420,
              child: FrostPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Connected services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    SizedBox(height: 18),
                    ServiceConnectionCard(name: 'Trakt', detail: 'Watchlist import • Continue Watching sync', icon: Icons.movie_filter_rounded),
                    SizedBox(height: 14),
                    ServiceConnectionCard(name: 'MyAnimeList', detail: 'Anime episode progress paired', icon: Icons.animation_rounded),
                    SizedBox(height: 14),
                    ServiceConnectionCard(name: 'Kitsu', detail: 'Season-level anime tracking enabled', icon: Icons.auto_awesome_rounded),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 420,
              child: FrostPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Privacy & device behavior', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 18),
                    SettingToggleLine(
                      title: 'DNS-over-HTTPS',
                      subtitle: 'Hide DNS queries from the ISP on supported devices.',
                      value: _dohEnabled,
                      onChanged: (value) => setState(() => _dohEnabled = value),
                    ),
                    const SizedBox(height: 18),
                    const SettingLine(label: 'Language pack', value: 'Hungarian • English • Japanese'),
                    const SizedBox(height: 14),
                    const SettingLine(label: 'TV navigation', value: 'Horizontal focus flow with larger targets'),
                    const SizedBox(height: 14),
                    const SettingLine(label: 'Parental labeling', value: 'Severity labels translated on detail pages'),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 420,
              child: FrostPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Network diagnostics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    const Text('Probe safe public endpoints and expose selective reachability directly inside the app.'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _probingNetwork ? null : _runNetworkProbe,
                      icon: Icon(_probingNetwork ? Icons.wifi_tethering_error_rounded : Icons.language_rounded),
                      label: Text(_probingNetwork ? 'Probing network...' : 'Run network probe'),
                    ),
                    const SizedBox(height: 18),
                    if (_networkResults.isEmpty)
                      const Text('No probe results yet. Launch diagnostics to see which endpoints are reachable in this runtime.')
                    else
                      ..._networkResults.map(
                        (result) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: NetworkProbeCard(result: result),
                        ),
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
