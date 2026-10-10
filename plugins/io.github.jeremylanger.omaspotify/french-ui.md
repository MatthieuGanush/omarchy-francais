---
id: french-ui
plugin: io.github.jeremylanger.omaspotify
title: Player, mini-player and settings in French
bootstrapped: false
enabled: true
applied:
  tree: b3208dbdcc3f07d5
  commit: 2de4676
  at: 2026-10-08T21:56:26Z
  version: 2.0.1
  source: ""
files:
  - Api.js
  - AuthManager.qml
  - BackendClient.qml
  - BarWidget.qml
  - CreatePlaylistPopup.qml
  - DaemonManager.qml
  - DetailPage.qml
  - DevicesPage.qml
  - DiscoverPage.qml
  - Equalizer.qml
  - HomePage.qml
  - I18n.js
  - LibraryPage.qml
  - ListeningHeatmap.qml
  - LoginPage.qml
  - LyricsInstallPrompt.qml
  - LyricsPlugin.qml
  - MediaByline.qml
  - MediaCollection.qml
  - MediaContextMenu.qml
  - MediaRow.qml
  - NowPlayingPage.qml
  - OAuth.js
  - Panel.qml
  - PlaylistPicker.qml
  - PlaylistsPage.qml
  - QueuePage.qml
  - SearchController.qml
  - SearchPage.qml
  - Service.qml
  - SettingsPage.qml
  - ShortcutHelpPopup.qml
  - SidebarRow.qml
  - SleepPopup.qml
  - SleepTimer.qml
  - SpotifyApi.qml
  - SpotifyConnectManager.qml
  - StatsPage.qml
---

# Player, mini-player and settings in French

## Goal

With a French system locale, OmaSpotify's full player, mini-player, bar
tooltips, settings, devices, search, library, sleep timer, shortcut help and
status/error messages are in French ("Pour vous", "Rechercher", "Titres
likés", "APPAREILS DISPONIBLES", "Disponible"…). Keyboard shortcuts keep
working, and stored settings keep their English values. Non-French locale:
upstream English.

## Why / decisions

User is French-speaking (Omarchy translated 2026-10-08). Same technique as
OmaWhatsApp's french-ui: plugin-local dictionary keyed on English literals.
Not translated on purpose: Spotify's own playlist names used for matching
(Discover Weekly, Release Radar, Daily Mix, Fresh Finds, New Music Friday,
"This Is "), HTTP verbs, debug/log strings, OAuth internals, and the
device-type words coming from the backend ("Speaker", "Gameconsole").
Shortened to fit: Library order → "Par défaut", Listening → "Mes écoutes".

## Where to look

- `I18n.js` (dictionary + `t()`)
- Every QML/JS literal in display position; `SettingsPage.qml` On/Off,
  shortcut-player and volume-level displays.

## Prior art

Captured against version 2.0.1 (`2de4676`). Source table
`~/omarchy-francais/plugins/io.github.jeremylanger.omaspotify/outils/translations-fr.tsv` (English<TAB>French)
and the wrapping script `rewrap.py` (run: `python3 rewrap.py <plugin dir>`
after regenerating I18n.js from the table).

- Wrapping rule: `"X"` → `I18n.t("X")` for each key, longest first, except
  after `=== `/`!== `/`case `, before `===`/`!==`, or immediately before
  `:` (object key). ~900 sites. Import after the last QML import / after
  `.pragma library` in Api.js, OAuth.js.
- Shortcut guard: on lines with `sequences:`/`sequence:`/`Shortcut {`/
  `matches(`, key names (Space, Esc, Up, Down, Left, Right, Return, Enter,
  Tab) stay raw strings — translating them breaks the bindings.
- Setting VALUES must stay English: "On", "Off", "Quiet", "Normal", "Loud",
  "Full player", "Mini player", "Omarchy Music app" are unwrapped everywhere,
  then translated only at display: SettingsPage
  `(page.panel.draftX ? "On" : "Off")` → `I18n.t(page.panel.draftX ? "On" : "Off")`
  (10 sites), `"Super + Shift + M · " + I18n.t(page.panel.draftShortcutPlayer)`,
  `I18n.t("Volume level · ") + I18n.t(page.panel.volumeLevelLabel())`.
- Uppercase section headings added separately (SONGS, RESULTS, PLAYBACK,
  AVAILABLE DEVICES…; not NORMAL/HOME/GET/PUT/POST/DELETE/HEAD).
- Not changed: tests/, backend/ (Rust), the existing service-qml record.

## Re-apply notes

omarchy-restart-shell, then `omarchy-shell shell toggle
io.github.jeremylanger.omaspotify` and grim only the OmaSpotify window
(`hyprctl clients`, title OmaSpotify): sidebar "Pour vous / Rechercher /
Découvrir / En cours de lecture / File d'attente / Mes écoutes / Titres
likés / Réglages", devices "APPAREILS DISPONIBLES", "Disponible". Check a
setting toggle still persists (On/Off values in shell.json stay English).
