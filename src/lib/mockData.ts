import type {
  AppSettings,
  DownloadItem,
  MediaItem,
  Profile,
  ProviderConfig,
  SyncConnection,
  WatchProgress,
} from "./types";

const bunnyCaptions = [
  { start: 2, end: 6, text: "Welcome back to FlixNest's cinematic control room." },
  { start: 8, end: 13, text: "This player keeps intro skip, subtitles and sync within reach." },
  { start: 18, end: 23, text: "Hold the boost button whenever you want a quick scan through a scene." },
];

export const mediaLibrary: MediaItem[] = [
  {
    id: "orbital-archive",
    title: "Orbital Archive",
    tagline: "A premium catalog lane tuned for desktop, phone and TV surfaces.",
    year: 2026,
    durationMinutes: 16,
    rating: 9.1,
    genres: ["Sci-Fi", "Adventure", "Featured"],
    synopsis:
      "A polished public-domain showcase title used to demonstrate responsive shelves, continue watching sync, intro skipping and subtitle customization inside FlixNest.",
    categories: ["Featured", "Continue Watching", "Trending", "Sci-Fi"],
    heroGradient: "linear-gradient(135deg, rgba(99,102,241,.95), rgba(14,165,233,.8), rgba(236,72,153,.75))",
    cardGradient: "linear-gradient(160deg, rgba(79,70,229,.95), rgba(6,182,212,.75))",
    sourceUrl: "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    intro: { start: 3, end: 11 },
    subtitles: bunnyCaptions,
    audioProfiles: ["Stereo", "Spatial", "Director's Mix"],
    parental: { age: "12+", warnings: ["Mild fantasy action"], severity: "low" },
  },
  {
    id: "sintel-nova",
    title: "Sintel Nova",
    tagline: "Glassmorphism, deep contrast and 10-foot navigation in one surface.",
    year: 2025,
    durationMinutes: 15,
    rating: 8.8,
    genres: ["Fantasy", "Animation"],
    synopsis:
      "A dramatic showcase entry with strong banner visuals, making it ideal for hero carousels and immersive TV mode testing.",
    categories: ["Featured", "New Releases", "Fantasy"],
    heroGradient: "linear-gradient(135deg, rgba(15,23,42,.92), rgba(251,113,133,.78), rgba(251,191,36,.7))",
    cardGradient: "linear-gradient(180deg, rgba(225,29,72,.85), rgba(217,70,239,.65))",
    sourceUrl: "https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
    intro: { start: 2, end: 8 },
    subtitles: [
      { start: 4, end: 8, text: "Immersive detail pages adapt naturally between touch and remote control." },
      { start: 9, end: 14, text: "Profiles, downloads and provider priorities stay in sync locally." },
    ],
    audioProfiles: ["Stereo", "Atmos-ready"],
    parental: { age: "13+", warnings: ["Fantasy peril", "Thematic intensity"], severity: "medium" },
  },
  {
    id: "elephant-signal",
    title: "Elephant Signal",
    tagline: "Reliable playback lanes with smart fallback ordering.",
    year: 2024,
    durationMinutes: 11,
    rating: 8.4,
    genres: ["Drama", "Demo"],
    synopsis:
      "Built for validating the provider management surface, smart queue cards and responsive metadata shelves.",
    categories: ["Trending", "Drama", "Because You Watched Orbital Archive"],
    heroGradient: "linear-gradient(135deg, rgba(12,74,110,.95), rgba(56,189,248,.8), rgba(34,197,94,.65))",
    cardGradient: "linear-gradient(150deg, rgba(8,145,178,.9), rgba(34,197,94,.72))",
    sourceUrl: "https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    intro: { start: 1, end: 7 },
    subtitles: [
      { start: 2, end: 7, text: "Provider fallback keeps the next source ready when one path fails." },
      { start: 8, end: 12, text: "Everything here is aimed at legal, personal or public-domain playback." },
    ],
    audioProfiles: ["Stereo", "Night mode"],
    parental: { age: "10+", warnings: ["Abstract imagery"], severity: "low" },
  },
  {
    id: "joyride-grid",
    title: "Joyride Grid",
    tagline: "Fast start-up and curated lanes for large libraries.",
    year: 2023,
    durationMinutes: 10,
    rating: 8.2,
    genres: ["Action", "UI Test"],
    synopsis:
      "A compact title that keeps download and sync examples visible while stress-testing shelves on narrow screens.",
    categories: ["New Releases", "Action", "Continue Watching"],
    heroGradient: "linear-gradient(135deg, rgba(22,78,99,.95), rgba(249,115,22,.8), rgba(234,179,8,.75))",
    cardGradient: "linear-gradient(150deg, rgba(249,115,22,.88), rgba(250,204,21,.72))",
    sourceUrl: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
    intro: { start: 2, end: 6 },
    subtitles: [
      { start: 2, end: 6, text: "Queue entire collections, keep structure tidy and continue instantly offline." },
      { start: 6, end: 11, text: "The same shell scales from handheld to couch-ready TV mode." },
    ],
    audioProfiles: ["Stereo", "Boosted dialogue"],
    parental: { age: "7+", warnings: ["Fast motion"], severity: "low" },
  },
];

export const defaultSettings: AppSettings = {
  language: "hu",
  theme: "midnight",
  viewMode: "immersive",
  showHero: true,
  tvMode: false,
  engine: "auto",
  decoder: "auto",
  renderer: "gpu",
  aspectRatio: "fit",
  subtitlesEnabled: true,
  subtitleSize: 20,
  pictureInPicture: true,
  basePlaybackRate: 1,
  externalPlayer: true,
};

export const defaultProviders: ProviderConfig[] = [
  {
    id: "local-library",
    name: "Local Library",
    type: "catalog",
    endpoint: "file://library",
    enabled: true,
    description: "Personal files and folders added by the user.",
    source: "built-in",
  },
  {
    id: "public-domain",
    name: "Public Domain Vault",
    type: "catalog",
    endpoint: "https://archive.org/details/movies",
    enabled: true,
    description: "Public-domain and openly licensed showcase content.",
    source: "built-in",
  },
  {
    id: "metadata-core",
    name: "Metadata Core",
    type: "metadata",
    endpoint: "local://metadata-cache",
    enabled: true,
    description: "Local metadata enrichment, parental guide and continue watching state.",
    source: "built-in",
  },
  {
    id: "subtitle-room",
    name: "Subtitle Room",
    type: "subtitles",
    endpoint: "local://subtitle-room",
    enabled: true,
    description: "Internal and imported subtitle tracks for your authorized media.",
    source: "built-in",
  },
  {
    id: "trakt-sync",
    name: "Trakt Sync",
    type: "sync",
    endpoint: "oauth://trakt",
    enabled: false,
    description: "Watchlist and viewing history sync once connected.",
    source: "built-in",
  },
];

export const defaultProfiles: Profile[] = [
  { id: "owner", name: "Sándor", accent: "#8b5cf6", kidMode: false, language: "hu" },
  { id: "family", name: "Family", accent: "#06b6d4", kidMode: false, language: "en" },
  { id: "kids", name: "Kids", accent: "#f97316", kidMode: true, language: "hu" },
];

export const defaultConnections: SyncConnection[] = [
  {
    id: "trakt",
    name: "Trakt.tv",
    description: "Watchlist import, scrobbling and continue-watching sync.",
    connected: false,
    status: "Ready to connect",
  },
  {
    id: "mal",
    name: "MyAnimeList",
    description: "Anime episode progress and seasonal lists.",
    connected: false,
    status: "Ready to connect",
  },
  {
    id: "kitsu",
    name: "Kitsu",
    description: "Anime profile sync for teams and multi-profile households.",
    connected: false,
    status: "Ready to connect",
  },
];

export const seededProgress: Record<string, WatchProgress> = {
  "orbital-archive": {
    currentTime: 194,
    duration: 596,
    updatedAt: new Date().toISOString(),
    profileId: "owner",
  },
  "joyride-grid": {
    currentTime: 121,
    duration: 910,
    updatedAt: new Date(Date.now() - 1000 * 60 * 42).toISOString(),
    profileId: "family",
  },
};

export const seededDownloads: DownloadItem[] = [
  { mediaId: "orbital-archive", status: "downloaded", progress: 100 },
  { mediaId: "joyride-grid", status: "syncing", progress: 68 },
];
