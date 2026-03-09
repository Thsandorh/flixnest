export type AppView =
  | "discover"
  | "player"
  | "downloads"
  | "providers"
  | "sync"
  | "profiles"
  | "settings";

export type Language = "en" | "hu";
export type ThemeMode = "midnight" | "aurora";
export type ViewMode = "immersive" | "classic";
export type EngineMode = "auto" | "exo" | "mpv";
export type DecoderMode = "auto" | "hardware" | "hybrid";
export type RendererMode = "gpu" | "gpu-next";
export type AspectRatioMode = "fit" | "fill" | "crop";
export type ProviderType = "catalog" | "metadata" | "subtitles" | "sync";
export type ProviderSource = "built-in" | "custom";
export type DownloadStatus = "queued" | "syncing" | "downloaded";

export interface SubtitleCue {
  start: number;
  end: number;
  text: string;
}

export interface MediaItem {
  id: string;
  title: string;
  tagline: string;
  year: number;
  durationMinutes: number;
  rating: number;
  genres: string[];
  synopsis: string;
  categories: string[];
  heroGradient: string;
  cardGradient: string;
  sourceUrl: string;
  intro: {
    start: number;
    end: number;
  };
  subtitles: SubtitleCue[];
  audioProfiles: string[];
  parental: {
    age: string;
    warnings: string[];
    severity: "low" | "medium" | "high";
  };
}

export interface ProviderConfig {
  id: string;
  name: string;
  type: ProviderType;
  endpoint: string;
  enabled: boolean;
  description: string;
  source: ProviderSource;
}

export interface Profile {
  id: string;
  name: string;
  accent: string;
  kidMode: boolean;
  language: Language;
}

export interface SyncConnection {
  id: "trakt" | "mal" | "kitsu";
  name: string;
  description: string;
  connected: boolean;
  status: string;
}

export interface AppSettings {
  language: Language;
  theme: ThemeMode;
  viewMode: ViewMode;
  showHero: boolean;
  tvMode: boolean;
  engine: EngineMode;
  decoder: DecoderMode;
  renderer: RendererMode;
  aspectRatio: AspectRatioMode;
  subtitlesEnabled: boolean;
  subtitleSize: number;
  pictureInPicture: boolean;
  basePlaybackRate: number;
  externalPlayer: boolean;
}

export interface WatchProgress {
  currentTime: number;
  duration: number;
  updatedAt: string;
  profileId: string;
}

export interface DownloadItem {
  mediaId: string;
  status: DownloadStatus;
  progress: number;
}
