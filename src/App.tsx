import { useEffect, useMemo, useRef, useState } from "react";
import { openUrl } from "@tauri-apps/plugin-opener";
import "./App.css";
import {
  defaultConnections,
  defaultProfiles,
  defaultProviders,
  defaultSettings,
  mediaLibrary,
  seededDownloads,
  seededProgress,
} from "./lib/mockData";
import { usePersistentState } from "./lib/usePersistentState";
import type {
  AppSettings,
  AppView,
  MediaItem,
  Profile,
  ProviderConfig,
  SyncConnection,
  WatchProgress,
} from "./lib/types";

const copy = {
  hu: {
    brand: "FlixNest",
    tagline: "Modern, gyors és többplatformos médiaélmény legális forrásokra építve.",
    search: "Keresés címre, műfajra vagy hangulatra",
    resume: "Folytatás",
    featured: "Kiemelt",
    downloads: "Letöltések",
    providers: "Provider-ek",
    sync: "Szinkron",
    profiles: "Profilok",
    settings: "Beállítások",
    discover: "Felfedezés",
    player: "Lejátszó",
    playNow: "Lejátszás",
    queueOffline: "Offline mentés",
    removeOffline: "Letöltés törlése",
    launchExternal: "Megnyitás külső lejátszóban",
    intro: "Intró átugrása",
    pip: "Kép a képben",
    holdBoost: "Nyomva tartva gyorsítás",
    continueWatching: "Folytatásra vár",
    providerPriority: "Provider prioritás és fallback",
    addProvider: "Egyedi provider hozzáadása",
    save: "Mentés",
    addProfile: "Új profil",
    connected: "Kapcsolódva",
    connect: "Kapcsolódás",
    disconnect: "Kapcsolat bontása",
    tvMode: "TV mód",
    subtitleSize: "Felirat méret",
    viewMode: "Nézet",
    theme: "Téma",
    engine: "Lejátszómotor",
    decoder: "Dekódolás",
    renderer: "Renderelés",
    aspect: "Képarány",
    subtitles: "Feliratok",
    speed: "Alapsebesség",
    hero: "Hero szekció",
    language: "Nyelv",
    status: "Állapot",
    legalNote: "A FlixNest csak saját, nyilvános vagy engedélyezett forrásokra van felkészítve.",
  },
  en: {
    brand: "FlixNest",
    tagline: "Modern, fast and cross-platform media for legal libraries and authorized sources.",
    search: "Search by title, genre or mood",
    resume: "Resume",
    featured: "Featured",
    downloads: "Downloads",
    providers: "Providers",
    sync: "Sync",
    profiles: "Profiles",
    settings: "Settings",
    discover: "Discover",
    player: "Player",
    playNow: "Play now",
    queueOffline: "Save offline",
    removeOffline: "Remove download",
    launchExternal: "Open in external player",
    intro: "Skip intro",
    pip: "Picture in Picture",
    holdBoost: "Hold to boost",
    continueWatching: "Continue watching",
    providerPriority: "Provider priority & fallback",
    addProvider: "Add custom provider",
    save: "Save",
    addProfile: "New profile",
    connected: "Connected",
    connect: "Connect",
    disconnect: "Disconnect",
    tvMode: "TV mode",
    subtitleSize: "Subtitle size",
    viewMode: "View mode",
    theme: "Theme",
    engine: "Playback engine",
    decoder: "Decoding",
    renderer: "Rendering",
    aspect: "Aspect ratio",
    subtitles: "Subtitles",
    speed: "Base speed",
    hero: "Hero section",
    language: "Language",
    status: "Status",
    legalNote: "FlixNest is configured for personal, public-domain or otherwise authorized media sources.",
  },
} as const;

const navItems: { id: AppView; icon: string }[] = [
  { id: "discover", icon: "⌂" },
  { id: "player", icon: "▶" },
  { id: "downloads", icon: "⇩" },
  { id: "providers", icon: "◫" },
  { id: "sync", icon: "⟲" },
  { id: "profiles", icon: "☺" },
  { id: "settings", icon: "⚙" },
];

const aspectFitMap: Record<AppSettings["aspectRatio"], React.CSSProperties["objectFit"]> = {
  fit: "contain",
  fill: "fill",
  crop: "cover",
};

const viewModeLabels = {
  immersive: { hu: "Modern", en: "Immersive" },
  classic: { hu: "Klasszikus", en: "Classic" },
};

function formatMinutes(minutes: number) {
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  return hours > 0 ? `${hours}h ${mins}m` : `${mins}m`;
}

function formatProgress(progress?: WatchProgress) {
  if (!progress || !progress.duration) {
    return "0%";
  }

  return `${Math.min(100, Math.round((progress.currentTime / progress.duration) * 100))}%`;
}

function App() {
  const [settings, setSettings] = usePersistentState("flixnest:settings", defaultSettings);
  const [providers, setProviders] = usePersistentState("flixnest:providers", defaultProviders);
  const [profiles, setProfiles] = usePersistentState("flixnest:profiles", defaultProfiles);
  const [connections, setConnections] = usePersistentState("flixnest:connections", defaultConnections);
  const [downloads, setDownloads] = usePersistentState("flixnest:downloads", seededDownloads);
  const [progressMap, setProgressMap] = usePersistentState<Record<string, WatchProgress>>(
    "flixnest:progress",
    seededProgress,
  );
  const [activeView, setActiveView] = useState<AppView>("discover");
  const [selectedMediaId, setSelectedMediaId] = useState(mediaLibrary[0].id);
  const [activeProfileId, setActiveProfileId] = usePersistentState("flixnest:active-profile", defaultProfiles[0].id);
  const [search, setSearch] = useState("");
  const [providerDraft, setProviderDraft] = useState({ name: "", endpoint: "", type: "catalog" as ProviderConfig["type"] });
  const [profileDraft, setProfileDraft] = useState({ name: "", accent: "#22c55e" });
  const [playerTime, setPlayerTime] = useState(0);
  const [boosting, setBoosting] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);

  const t = copy[settings.language];
  const selectedMedia = mediaLibrary.find((item) => item.id === selectedMediaId) ?? mediaLibrary[0];
  const activeProfile = profiles.find((profile) => profile.id === activeProfileId) ?? profiles[0];

  const filteredMedia = useMemo(() => {
    const query = search.trim().toLowerCase();
    if (!query) {
      return mediaLibrary;
    }

    return mediaLibrary.filter((item) => {
      const haystack = [item.title, item.tagline, item.synopsis, ...item.genres, ...item.categories]
        .join(" ")
        .toLowerCase();
      return haystack.includes(query);
    });
  }, [search]);

  const sections = useMemo(() => {
    const groups = new Map<string, MediaItem[]>();
    filteredMedia.forEach((item) => {
      item.categories.forEach((category) => {
        if (!groups.has(category)) {
          groups.set(category, []);
        }
        groups.get(category)?.push(item);
      });
    });
    return [...groups.entries()];
  }, [filteredMedia]);

  const continueWatching = useMemo(
    () =>
      mediaLibrary
        .filter((item) => progressMap[item.id])
        .sort(
          (a, b) =>
            new Date(progressMap[b.id]?.updatedAt ?? 0).getTime() -
            new Date(progressMap[a.id]?.updatedAt ?? 0).getTime(),
        ),
    [progressMap],
  );

  const selectedDownload = downloads.find((item) => item.mediaId === selectedMedia.id);
  const introVisible = playerTime >= selectedMedia.intro.start && playerTime <= selectedMedia.intro.end;
  const activeSubtitle = settings.subtitlesEnabled
    ? selectedMedia.subtitles.find((cue) => playerTime >= cue.start && playerTime <= cue.end)
    : undefined;

  useEffect(() => {
    const current = videoRef.current;
    if (!current) {
      return;
    }

    current.playbackRate = boosting ? 1.75 : settings.basePlaybackRate;
  }, [boosting, settings.basePlaybackRate, selectedMediaId]);

  const playMedia = (mediaId: string) => {
    setSelectedMediaId(mediaId);
    setActiveView("player");
    setPlayerTime(progressMap[mediaId]?.currentTime ?? 0);
  };

  const updateProgress = (mediaId: string, currentTime: number, duration: number) => {
    setProgressMap((current) => ({
      ...current,
      [mediaId]: {
        currentTime,
        duration,
        updatedAt: new Date().toISOString(),
        profileId: activeProfileId,
      },
    }));
  };

  const toggleDownload = (mediaId: string) => {
    setDownloads((current) => {
      const existing = current.find((item) => item.mediaId === mediaId);
      if (existing) {
        return current.filter((item) => item.mediaId !== mediaId);
      }

      return [...current, { mediaId, status: "queued", progress: 0 }];
    });
  };

  const changeProvider = (providerId: string, patch: Partial<ProviderConfig>) => {
    setProviders((current) => current.map((provider) => (provider.id === providerId ? { ...provider, ...patch } : provider)));
  };

  const moveProvider = (providerId: string, direction: -1 | 1) => {
    setProviders((current) => {
      const index = current.findIndex((provider) => provider.id === providerId);
      const target = index + direction;
      if (index < 0 || target < 0 || target >= current.length) {
        return current;
      }

      const next = [...current];
      const [provider] = next.splice(index, 1);
      next.splice(target, 0, provider);
      return next;
    });
  };

  const addProvider = () => {
    if (!providerDraft.name.trim() || !providerDraft.endpoint.trim()) {
      return;
    }

    setProviders((current) => [
      ...current,
      {
        id: `custom-${Date.now()}`,
        name: providerDraft.name.trim(),
        endpoint: providerDraft.endpoint.trim(),
        enabled: true,
        description: "Custom provider endpoint for authorized catalogs or metadata.",
        source: "custom",
        type: providerDraft.type,
      },
    ]);
    setProviderDraft({ name: "", endpoint: "", type: "catalog" });
  };

  const addProfile = () => {
    if (!profileDraft.name.trim()) {
      return;
    }

    const newProfile: Profile = {
      id: `profile-${Date.now()}`,
      name: profileDraft.name.trim(),
      accent: profileDraft.accent,
      kidMode: false,
      language: settings.language,
    };

    setProfiles((current) => [...current, newProfile]);
    setActiveProfileId(newProfile.id);
    setProfileDraft({ name: "", accent: "#22c55e" });
  };

  const toggleConnection = (connectionId: SyncConnection["id"]) => {
    setConnections((current) =>
      current.map((connection) =>
        connection.id === connectionId
          ? {
              ...connection,
              connected: !connection.connected,
              status: connection.connected ? "Ready to connect" : `${activeProfile.name} profile linked`,
            }
          : connection,
      ),
    );
  };

  const launchExternalPlayer = async () => {
    try {
      await openUrl(selectedMedia.sourceUrl);
    } catch {
      window.open(selectedMedia.sourceUrl, "_blank", "noopener,noreferrer");
    }
  };

  const requestPictureInPicture = async () => {
    if (!settings.pictureInPicture || !videoRef.current || !("requestPictureInPicture" in videoRef.current)) {
      return;
    }

    try {
      await videoRef.current.requestPictureInPicture();
    } catch {
      // Ignore browser limitations; the button still documents the flow.
    }
  };

  const updateSetting = <K extends keyof AppSettings>(key: K, value: AppSettings[K]) => {
    setSettings((current) => ({ ...current, [key]: value }));
  };

  return (
    <div className={`app-shell theme-${settings.theme} ${settings.tvMode ? "tv-mode" : ""}`}>
      <aside className="sidebar glass-panel">
        <div className="brand-block">
          <div className="brand-mark">FN</div>
          <div>
            <h1>{t.brand}</h1>
            <p>{t.tagline}</p>
          </div>
        </div>

        <div className="profile-chip" style={{ borderColor: activeProfile.accent }}>
          <span className="profile-badge" style={{ background: activeProfile.accent }} />
          <div>
            <strong>{activeProfile.name}</strong>
            <small>{activeProfile.kidMode ? "Kids mode" : "Primary profile"}</small>
          </div>
        </div>

        <nav className="sidebar-nav">
          {navItems.map((item) => (
            <button
              key={item.id}
              className={`nav-button ${activeView === item.id ? "active" : ""}`}
              onClick={() => setActiveView(item.id)}
              type="button"
            >
              <span>{item.icon}</span>
              <span>{t[item.id]}</span>
            </button>
          ))}
        </nav>

        <div className="legal-note glass-soft">
          <strong>Legal-first</strong>
          <p>{t.legalNote}</p>
        </div>
      </aside>

      <main className="main-panel">
        <header className="topbar glass-panel">
          <label className="search-field">
            <span>⌕</span>
            <input value={search} onChange={(event) => setSearch(event.target.value)} placeholder={t.search} />
          </label>

          <div className="topbar-actions">
            <button type="button" className="ghost-button" onClick={() => updateSetting("tvMode", !settings.tvMode)}>
              {t.tvMode}: {settings.tvMode ? "On" : "Off"}
            </button>
            <button
              type="button"
              className="ghost-button"
              onClick={() => updateSetting("language", settings.language === "hu" ? "en" : "hu")}
            >
              {t.language}: {settings.language.toUpperCase()}
            </button>
          </div>
        </header>

        {activeView === "discover" && (
          <section className="view-stack">
            {settings.showHero && (
              <article className="hero-card" style={{ background: selectedMedia.heroGradient }}>
                <div className="hero-content">
                  <span className="eyebrow">{t.featured}</span>
                  <h2>{selectedMedia.title}</h2>
                  <p>{selectedMedia.synopsis}</p>
                  <div className="meta-row">
                    <span>{selectedMedia.year}</span>
                    <span>{formatMinutes(selectedMedia.durationMinutes)}</span>
                    <span>★ {selectedMedia.rating}</span>
                    <span>{selectedMedia.parental.age}</span>
                  </div>
                  <div className="hero-actions">
                    <button type="button" className="primary-button" onClick={() => playMedia(selectedMedia.id)}>
                      {t.playNow}
                    </button>
                    <button type="button" className="secondary-button" onClick={() => toggleDownload(selectedMedia.id)}>
                      {selectedDownload ? t.removeOffline : t.queueOffline}
                    </button>
                  </div>
                </div>
                <div className="hero-side glass-panel">
                  <div className="metric-card">
                    <strong>Dual profile ready</strong>
                    <span>{profiles.length} active profiles</span>
                  </div>
                  <div className="metric-card">
                    <strong>Smart fallback</strong>
                    <span>{providers.filter((provider) => provider.enabled).length} providers enabled</span>
                  </div>
                  <div className="metric-card">
                    <strong>Continue watching</strong>
                    <span>{continueWatching.length} active sessions</span>
                  </div>
                </div>
              </article>
            )}

            <section className="section-block">
              <div className="section-heading">
                <div>
                  <span className="eyebrow">{t.continueWatching}</span>
                  <h3>{activeProfile.name}</h3>
                </div>
                <span className="status-pill">{continueWatching.length} items</span>
              </div>
              <div className="card-grid continue-grid">
                {continueWatching.map((item) => (
                  <article key={item.id} className="media-card glass-panel" style={{ background: item.cardGradient }}>
                    <div>
                      <span className="eyebrow">{formatProgress(progressMap[item.id])}</span>
                      <h4>{item.title}</h4>
                      <p>{item.tagline}</p>
                    </div>
                    <div className="card-footer">
                      <div className="progress-track">
                        <span style={{ width: formatProgress(progressMap[item.id]) }} />
                      </div>
                      <button type="button" className="inline-button" onClick={() => playMedia(item.id)}>
                        {t.resume}
                      </button>
                    </div>
                  </article>
                ))}
              </div>
            </section>

            {sections.map(([sectionName, items]) => (
              <section key={sectionName} className="section-block">
                <div className="section-heading">
                  <div>
                    <span className="eyebrow">Shelf</span>
                    <h3>{sectionName}</h3>
                  </div>
                  <span className="status-pill">{items.length}</span>
                </div>
                <div className={`card-grid ${settings.viewMode === "classic" ? "classic-grid" : "poster-grid"}`}>
                  {items.map((item) => {
                    const itemDownload = downloads.find((entry) => entry.mediaId === item.id);
                    return (
                      <article key={`${sectionName}-${item.id}`} className="media-card poster-card glass-panel">
                        <div className="poster-art" style={{ background: item.cardGradient }}>
                          <span>{item.year}</span>
                          <h4>{item.title}</h4>
                          <small>{item.genres.join(" • ")}</small>
                        </div>
                        <div className="poster-body">
                          <p>{item.tagline}</p>
                          <div className="badge-row">
                            <span className={`badge severity-${item.parental.severity}`}>{item.parental.age}</span>
                            {item.parental.warnings.map((warning) => (
                              <span className="badge subtle" key={warning}>
                                {warning}
                              </span>
                            ))}
                          </div>
                          <div className="card-actions">
                            <button type="button" className="inline-button" onClick={() => playMedia(item.id)}>
                              {t.playNow}
                            </button>
                            <button type="button" className="icon-button" onClick={() => toggleDownload(item.id)}>
                              {itemDownload ? "✓" : "+"}
                            </button>
                          </div>
                        </div>
                      </article>
                    );
                  })}
                </div>
              </section>
            ))}
          </section>
        )}

        {activeView === "player" && (
          <section className="player-layout">
            <article className="player-frame glass-panel">
              <div className="player-header">
                <div>
                  <span className="eyebrow">{t.player}</span>
                  <h2>{selectedMedia.title}</h2>
                  <p>{selectedMedia.tagline}</p>
                </div>
                <div className="badge-row">
                  <span className="badge">{settings.engine.toUpperCase()}</span>
                  <span className="badge">{settings.decoder}</span>
                  <span className="badge">{settings.renderer}</span>
                </div>
              </div>

              <div className="video-shell" onPointerUp={() => setBoosting(false)} onPointerCancel={() => setBoosting(false)}>
                <video
                  key={selectedMedia.id}
                  ref={videoRef}
                  className="video-player"
                  controls
                  playsInline
                  src={selectedMedia.sourceUrl}
                  preload="metadata"
                  style={{ objectFit: aspectFitMap[settings.aspectRatio] }}
                  onLoadedMetadata={(event) => {
                    const savedTime = progressMap[selectedMedia.id]?.currentTime ?? 0;
                    event.currentTarget.currentTime = savedTime;
                    setPlayerTime(savedTime);
                  }}
                  onTimeUpdate={(event) => {
                    const currentTime = event.currentTarget.currentTime;
                    const duration = event.currentTarget.duration || 1;
                    setPlayerTime(currentTime);
                    updateProgress(selectedMedia.id, currentTime, duration);
                  }}
                />
                {activeSubtitle && <div className="subtitle-overlay" style={{ fontSize: settings.subtitleSize }}>{activeSubtitle.text}</div>}
                <div className="video-overlay-top">
                  {introVisible && (
                    <button
                      type="button"
                      className="primary-button compact"
                      onClick={() => {
                        if (videoRef.current) {
                          videoRef.current.currentTime = selectedMedia.intro.end;
                        }
                      }}
                    >
                      {t.intro}
                    </button>
                  )}
                  <button type="button" className="secondary-button compact" onClick={requestPictureInPicture}>
                    {t.pip}
                  </button>
                  <button type="button" className="secondary-button compact" onClick={launchExternalPlayer}>
                    {t.launchExternal}
                  </button>
                </div>
                <button
                  type="button"
                  className={`boost-button ${boosting ? "active" : ""}`}
                  onPointerDown={() => setBoosting(true)}
                  onPointerUp={() => setBoosting(false)}
                  onPointerLeave={() => setBoosting(false)}
                >
                  {t.holdBoost}
                </button>
              </div>
            </article>

            <aside className="player-sidebar">
              <section className="settings-card glass-panel">
                <div className="section-heading compact-heading">
                  <div>
                    <span className="eyebrow">Playback</span>
                    <h3>{selectedMedia.title}</h3>
                  </div>
                  <span className="status-pill">{formatProgress(progressMap[selectedMedia.id])}</span>
                </div>

                <div className="control-group">
                  <label>
                    {t.engine}
                    <select value={settings.engine} onChange={(event) => updateSetting("engine", event.target.value as AppSettings["engine"])}>
                      <option value="auto">Auto</option>
                      <option value="exo">Exo Profile</option>
                      <option value="mpv">MPV Profile</option>
                    </select>
                  </label>
                  <label>
                    {t.decoder}
                    <select value={settings.decoder} onChange={(event) => updateSetting("decoder", event.target.value as AppSettings["decoder"])}>
                      <option value="auto">Auto</option>
                      <option value="hardware">HW</option>
                      <option value="hybrid">HW + SW</option>
                    </select>
                  </label>
                </div>

                <div className="control-group">
                  <label>
                    {t.renderer}
                    <select value={settings.renderer} onChange={(event) => updateSetting("renderer", event.target.value as AppSettings["renderer"])}>
                      <option value="gpu">GPU</option>
                      <option value="gpu-next">GPU Next</option>
                    </select>
                  </label>
                  <label>
                    {t.aspect}
                    <select
                      value={settings.aspectRatio}
                      onChange={(event) => updateSetting("aspectRatio", event.target.value as AppSettings["aspectRatio"])}
                    >
                      <option value="fit">Fit</option>
                      <option value="fill">Fill</option>
                      <option value="crop">Crop</option>
                    </select>
                  </label>
                </div>

                <div className="control-group">
                  <label>
                    {t.speed}
                    <select
                      value={settings.basePlaybackRate}
                      onChange={(event) => updateSetting("basePlaybackRate", Number(event.target.value))}
                    >
                      {[0.75, 1, 1.25, 1.5].map((speed) => (
                        <option key={speed} value={speed}>
                          {speed.toFixed(2)}x
                        </option>
                      ))}
                    </select>
                  </label>
                  <label>
                    {t.subtitleSize}
                    <input
                      type="range"
                      min="16"
                      max="34"
                      step="1"
                      value={settings.subtitleSize}
                      onChange={(event) => updateSetting("subtitleSize", Number(event.target.value))}
                    />
                  </label>
                </div>

                <div className="toggle-row">
                  <button type="button" className={`toggle-pill ${settings.subtitlesEnabled ? "active" : ""}`} onClick={() => updateSetting("subtitlesEnabled", !settings.subtitlesEnabled)}>
                    {t.subtitles}
                  </button>
                  <button type="button" className={`toggle-pill ${settings.pictureInPicture ? "active" : ""}`} onClick={() => updateSetting("pictureInPicture", !settings.pictureInPicture)}>
                    PiP
                  </button>
                  <button type="button" className={`toggle-pill ${settings.externalPlayer ? "active" : ""}`} onClick={() => updateSetting("externalPlayer", !settings.externalPlayer)}>
                    External
                  </button>
                </div>
              </section>

              <section className="details-card glass-panel">
                <h3>Parental guide</h3>
                <div className="badge-row">
                  <span className={`badge severity-${selectedMedia.parental.severity}`}>{selectedMedia.parental.age}</span>
                  {selectedMedia.parental.warnings.map((warning) => (
                    <span className="badge subtle" key={warning}>
                      {warning}
                    </span>
                  ))}
                </div>
                <p>{selectedMedia.synopsis}</p>
                <div className="audio-stack">
                  {selectedMedia.audioProfiles.map((profile) => (
                    <span key={profile} className="audio-chip">
                      {profile}
                    </span>
                  ))}
                </div>
              </section>
            </aside>
          </section>
        )}

        {activeView === "downloads" && (
          <section className="view-stack">
            <div className="section-heading">
              <div>
                <span className="eyebrow">Offline</span>
                <h2>{t.downloads}</h2>
              </div>
              <span className="status-pill">{downloads.length} tracked</span>
            </div>
            <div className="stack-grid">
              {downloads.map((download) => {
                const item = mediaLibrary.find((media) => media.id === download.mediaId);
                if (!item) {
                  return null;
                }
                return (
                  <article key={download.mediaId} className="download-card glass-panel">
                    <div className="download-art" style={{ background: item.cardGradient }} />
                    <div>
                      <h3>{item.title}</h3>
                      <p>{item.synopsis}</p>
                      <div className="progress-track large">
                        <span style={{ width: `${download.progress}%` }} />
                      </div>
                    </div>
                    <div className="download-status">
                      <span className="badge">{download.status}</span>
                      <span>{download.progress}%</span>
                    </div>
                  </article>
                );
              })}
            </div>
          </section>
        )}

        {activeView === "providers" && (
          <section className="view-stack">
            <div className="section-heading">
              <div>
                <span className="eyebrow">Catalog + metadata</span>
                <h2>{t.providerPriority}</h2>
              </div>
              <span className="status-pill">Fallback enabled</span>
            </div>

            <div className="stack-grid">
              {providers.map((provider, index) => (
                <article key={provider.id} className="provider-card glass-panel">
                  <div className="provider-header">
                    <div>
                      <span className="eyebrow">{provider.type}</span>
                      <input
                        value={provider.name}
                        onChange={(event) => changeProvider(provider.id, { name: event.target.value })}
                        className="inline-input"
                      />
                    </div>
                    <button type="button" className={`toggle-pill ${provider.enabled ? "active" : ""}`} onClick={() => changeProvider(provider.id, { enabled: !provider.enabled })}>
                      {provider.enabled ? "Enabled" : "Disabled"}
                    </button>
                  </div>
                  <p>{provider.description}</p>
                  <label>
                    Endpoint
                    <input
                      value={provider.endpoint}
                      onChange={(event) => changeProvider(provider.id, { endpoint: event.target.value })}
                    />
                  </label>
                  <div className="provider-actions">
                    <button type="button" className="ghost-button" onClick={() => moveProvider(provider.id, -1)} disabled={index === 0}>
                      ↑
                    </button>
                    <button
                      type="button"
                      className="ghost-button"
                      onClick={() => moveProvider(provider.id, 1)}
                      disabled={index === providers.length - 1}
                    >
                      ↓
                    </button>
                    <span className="status-pill">{provider.source}</span>
                  </div>
                </article>
              ))}
            </div>

            <article className="settings-card glass-panel">
              <div className="section-heading compact-heading">
                <div>
                  <span className="eyebrow">Custom</span>
                  <h3>{t.addProvider}</h3>
                </div>
              </div>
              <div className="control-group triple">
                <label>
                  Name
                  <input value={providerDraft.name} onChange={(event) => setProviderDraft((current) => ({ ...current, name: event.target.value }))} />
                </label>
                <label>
                  Endpoint
                  <input
                    value={providerDraft.endpoint}
                    onChange={(event) => setProviderDraft((current) => ({ ...current, endpoint: event.target.value }))}
                    placeholder="https://provider.example/api"
                  />
                </label>
                <label>
                  Type
                  <select value={providerDraft.type} onChange={(event) => setProviderDraft((current) => ({ ...current, type: event.target.value as ProviderConfig["type"] }))}>
                    <option value="catalog">Catalog</option>
                    <option value="metadata">Metadata</option>
                    <option value="subtitles">Subtitles</option>
                    <option value="sync">Sync</option>
                  </select>
                </label>
              </div>
              <button type="button" className="primary-button" onClick={addProvider}>
                {t.save}
              </button>
            </article>
          </section>
        )}

        {activeView === "sync" && (
          <section className="view-stack">
            <div className="section-heading">
              <div>
                <span className="eyebrow">Accounts</span>
                <h2>{t.sync}</h2>
              </div>
              <span className="status-pill">{connections.filter((item) => item.connected).length} linked</span>
            </div>
            <div className="stack-grid sync-grid">
              {connections.map((connection) => (
                <article key={connection.id} className="sync-card glass-panel">
                  <h3>{connection.name}</h3>
                  <p>{connection.description}</p>
                  <div className="sync-footer">
                    <span className="status-pill">{connection.status}</span>
                    <button type="button" className="primary-button" onClick={() => toggleConnection(connection.id)}>
                      {connection.connected ? t.disconnect : t.connect}
                    </button>
                  </div>
                </article>
              ))}
            </div>

            <article className="settings-card glass-panel">
              <div className="section-heading compact-heading">
                <div>
                  <span className="eyebrow">Continue watching</span>
                  <h3>Profile memory</h3>
                </div>
              </div>
              <div className="stats-row">
                <div className="metric-card glass-soft">
                  <strong>{Object.keys(progressMap).length}</strong>
                  <span>Tracked sessions</span>
                </div>
                <div className="metric-card glass-soft">
                  <strong>{profiles.length}</strong>
                  <span>Profiles synchronized locally</span>
                </div>
                <div className="metric-card glass-soft">
                  <strong>{downloads.filter((item) => item.status === "downloaded").length}</strong>
                  <span>Offline ready</span>
                </div>
              </div>
            </article>
          </section>
        )}

        {activeView === "profiles" && (
          <section className="view-stack">
            <div className="section-heading">
              <div>
                <span className="eyebrow">Household</span>
                <h2>{t.profiles}</h2>
              </div>
              <span className="status-pill">{profiles.length} profiles</span>
            </div>
            <div className="stack-grid profile-grid">
              {profiles.map((profile) => (
                <article key={profile.id} className="profile-card glass-panel" style={{ borderColor: profile.accent }}>
                  <div className="profile-card-header">
                    <span className="profile-badge large" style={{ background: profile.accent }} />
                    <div>
                      <h3>{profile.name}</h3>
                      <p>{profile.kidMode ? "Kid-safe recommendations" : "Full library access"}</p>
                    </div>
                  </div>
                  <div className="badge-row">
                    <span className="badge">{profile.language.toUpperCase()}</span>
                    <span className="badge subtle">{profile.kidMode ? "Kids" : "Standard"}</span>
                  </div>
                  <div className="provider-actions">
                    <button type="button" className="primary-button" onClick={() => setActiveProfileId(profile.id)}>
                      {activeProfileId === profile.id ? "Active" : "Switch"}
                    </button>
                    <button
                      type="button"
                      className={`toggle-pill ${profile.kidMode ? "active" : ""}`}
                      onClick={() =>
                        setProfiles((current) => current.map((item) => (item.id === profile.id ? { ...item, kidMode: !item.kidMode } : item)))
                      }
                    >
                      Kid mode
                    </button>
                  </div>
                </article>
              ))}
            </div>
            <article className="settings-card glass-panel">
              <div className="section-heading compact-heading">
                <div>
                  <span className="eyebrow">Create</span>
                  <h3>{t.addProfile}</h3>
                </div>
              </div>
              <div className="control-group triple">
                <label>
                  Name
                  <input value={profileDraft.name} onChange={(event) => setProfileDraft((current) => ({ ...current, name: event.target.value }))} />
                </label>
                <label>
                  Accent
                  <input type="color" value={profileDraft.accent} onChange={(event) => setProfileDraft((current) => ({ ...current, accent: event.target.value }))} />
                </label>
                <button type="button" className="primary-button align-end" onClick={addProfile}>
                  {t.save}
                </button>
              </div>
            </article>
          </section>
        )}

        {activeView === "settings" && (
          <section className="view-stack">
            <div className="section-heading">
              <div>
                <span className="eyebrow">System</span>
                <h2>{t.settings}</h2>
              </div>
              <span className="status-pill">Cross-platform shell</span>
            </div>
            <div className="settings-grid">
              <article className="settings-card glass-panel">
                <h3>Experience</h3>
                <div className="control-group">
                  <label>
                    {t.viewMode}
                    <select value={settings.viewMode} onChange={(event) => updateSetting("viewMode", event.target.value as AppSettings["viewMode"])}>
                      <option value="immersive">{viewModeLabels.immersive[settings.language]}</option>
                      <option value="classic">{viewModeLabels.classic[settings.language]}</option>
                    </select>
                  </label>
                  <label>
                    {t.theme}
                    <select value={settings.theme} onChange={(event) => updateSetting("theme", event.target.value as AppSettings["theme"])}>
                      <option value="midnight">Midnight</option>
                      <option value="aurora">Aurora</option>
                    </select>
                  </label>
                </div>
                <div className="toggle-row">
                  <button type="button" className={`toggle-pill ${settings.showHero ? "active" : ""}`} onClick={() => updateSetting("showHero", !settings.showHero)}>
                    {t.hero}
                  </button>
                  <button type="button" className={`toggle-pill ${settings.tvMode ? "active" : ""}`} onClick={() => updateSetting("tvMode", !settings.tvMode)}>
                    {t.tvMode}
                  </button>
                </div>
              </article>

              <article className="settings-card glass-panel">
                <h3>Playback defaults</h3>
                <div className="control-group">
                  <label>
                    {t.engine}
                    <select value={settings.engine} onChange={(event) => updateSetting("engine", event.target.value as AppSettings["engine"])}>
                      <option value="auto">Auto</option>
                      <option value="exo">Exo Profile</option>
                      <option value="mpv">MPV Profile</option>
                    </select>
                  </label>
                  <label>
                    {t.aspect}
                    <select value={settings.aspectRatio} onChange={(event) => updateSetting("aspectRatio", event.target.value as AppSettings["aspectRatio"])}>
                      <option value="fit">Fit</option>
                      <option value="fill">Fill</option>
                      <option value="crop">Crop</option>
                    </select>
                  </label>
                </div>
                <div className="toggle-row">
                  <button type="button" className={`toggle-pill ${settings.pictureInPicture ? "active" : ""}`} onClick={() => updateSetting("pictureInPicture", !settings.pictureInPicture)}>
                    PiP
                  </button>
                  <button type="button" className={`toggle-pill ${settings.subtitlesEnabled ? "active" : ""}`} onClick={() => updateSetting("subtitlesEnabled", !settings.subtitlesEnabled)}>
                    {t.subtitles}
                  </button>
                  <button type="button" className={`toggle-pill ${settings.externalPlayer ? "active" : ""}`} onClick={() => updateSetting("externalPlayer", !settings.externalPlayer)}>
                    External
                  </button>
                </div>
              </article>

              <article className="settings-card glass-panel">
                <h3>Platform readiness</h3>
                <div className="stats-row vertical">
                  <div className="metric-card glass-soft">
                    <strong>Desktop</strong>
                    <span>Tauri shell configured with branded window defaults.</span>
                  </div>
                  <div className="metric-card glass-soft">
                    <strong>Android</strong>
                    <span>Project prepared for `npm run tauri android init` and responsive TV mode.</span>
                  </div>
                  <div className="metric-card glass-soft">
                    <strong>Profiles + sync</strong>
                    <span>Persistent local storage for playback, downloads and provider ordering.</span>
                  </div>
                </div>
              </article>
            </div>
          </section>
        )}
      </main>

      <nav className="bottom-nav glass-panel">
        {navItems.slice(0, 5).map((item) => (
          <button key={item.id} className={`nav-button ${activeView === item.id ? "active" : ""}`} type="button" onClick={() => setActiveView(item.id)}>
            <span>{item.icon}</span>
            <span>{t[item.id]}</span>
          </button>
        ))}
      </nav>
    </div>
  );
}

export default App;
