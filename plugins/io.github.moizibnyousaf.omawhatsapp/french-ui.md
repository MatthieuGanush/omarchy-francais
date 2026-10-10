---
id: french-ui
plugin: io.github.moizibnyousaf.omawhatsapp
title: App, dropdown and popups in French
bootstrapped: false
enabled: true
applied:
  tree: d30db29e77578ad7
  commit: 4cd5770
  at: 2026-10-08T21:47:49Z
  version: 0.15.4
  source: ""
files:
  - plugins/omawhatsapp/I18n.js
  - plugins/omawhatsapp/AccountModel.js
  - plugins/omawhatsapp/AccountOperations.qml
  - plugins/omawhatsapp/AccountSwitcher.qml
  - plugins/omawhatsapp/AcknowledgementQueue.qml
  - plugins/omawhatsapp/App.qml
  - plugins/omawhatsapp/BarWidget.qml
  - plugins/omawhatsapp/ChatDetailsPanel.qml
  - plugins/omawhatsapp/ComposerModel.js
  - plugins/omawhatsapp/Dropdown.qml
  - plugins/omawhatsapp/EmojiModel.js
  - plugins/omawhatsapp/EmojiPicker.qml
  - plugins/omawhatsapp/FormatBar.qml
  - plugins/omawhatsapp/FormatMenu.qml
  - plugins/omawhatsapp/GroupAdmin.qml
  - plugins/omawhatsapp/GroupDialog.qml
  - plugins/omawhatsapp/LinkStatus.qml
  - plugins/omawhatsapp/MaintenanceSettings.qml
  - plugins/omawhatsapp/MediaBrowser.qml
  - plugins/omawhatsapp/MediaBubble.qml
  - plugins/omawhatsapp/MediaViewer.qml
  - plugins/omawhatsapp/MessageBubble.qml
  - plugins/omawhatsapp/NewChatDialog.qml
  - plugins/omawhatsapp/OnboardingView.qml
  - plugins/omawhatsapp/PresenceModel.js
  - plugins/omawhatsapp/QuickSwitcher.qml
  - plugins/omawhatsapp/Service.qml
  - plugins/omawhatsapp/SettingsView.qml
  - plugins/omawhatsapp/TimeFormat.js
  - plugins/omawhatsapp/UpdateController.qml
  - plugins/omawhatsapp/VideoPlayer.qml
  - plugins/omawhatsapp/VoiceComposer.qml
  - plugins/omawhatsapp/VoiceRecorder.qml
  - plugins/omawhatsapp/VoiceRecorderModel.js
  - bin/omawhatsapp_core.py
---

# App, dropdown and popups in French

## Goal

With a French system locale, OmaWhatsApp's full app, bar dropdown, settings,
dialogs, toasts, tooltips, day/date labels ("Aujourd'hui", "Hier", "lun.",
"8 oct.") and its desktop popups ("Nouveaux messages. Ouvrez OmaWhatsApp pour
les lire.", action "Ouvrir la discussion") are in French. Non-French locale:
upstream English, unchanged. Message content, contact names and emoji search
keywords are not touched.

## Why / decisions

User is French-speaking; rest of Omarchy translated 2026-10-08. Plugin has no
i18n, so a plugin-local dictionary keyed on exact English source literals,
including concatenation fragments ("Delete ", " messages?") because the app
builds sentences with +. Fragments give occasionally stiff French
("Alex : écrit…") but avoid rewriting hundreds of call sites. Labels shortened
to fit: Search chats/messages → "Rechercher", Search chats or
type a number → "Nom ou numéro", To reply → "À répondre".

## Where to look

- `plugins/omawhatsapp/I18n.js` (dictionary, `t()`, `fmt()`)
- Every QML/JS literal in display position; `TimeFormat.js` day/month names;
  `PresenceModel.js` lastSeenLabel; `MessageBubble.qml` quoted sender
- `bin/omawhatsapp_core.py`: `NOTIFY_GENERIC_BODY`, `NOTIFY_OPEN_ACTION`

## Prior art

Captured against version 0.15.4 (`4cd5770`). Copies of I18n.js and the
source table (`translations-fr.tsv`, English<TAB>French, 750 rows) are in
`~/omarchy-francais/plugins/io.github.moizibnyousaf.omawhatsapp/outils/` — regenerate I18n.js from the table if
upstream strings moved.

- New `I18n.js` (`.pragma library`): `fr` map, `french` from
  `Qt.locale().name`, `t(source)`, `fmt(date, pattern)` =
  `date.toLocaleString(Qt.locale(), t(pattern))` (pattern "ddd, MMM d · " →
  "ddd d MMM · ").
- Mechanical pass: `~/omarchy-francais/plugins/io.github.moizibnyousaf.omawhatsapp/outils/rewrap.py <plugins/omawhatsapp dir>`
  — for each key, longest first, `"X"` → `I18n.t("X")` in every QML/JS except
  I18n.js/FontScale.js; skipped after `=== `/`!== `/`case `, before
  `===`/`!==`, or immediately before `:` (object key). Key names in
  shortcut definitions (`sequences:`, `Shortcut {`) are kept raw. ~957 sites
  (first pass skipped multi-line ternaries; fixed 2026-10-08). Also
  `Qt.formatDateTime(`/`Qt.formatDate(` → `I18n.fmt(`. Import added after the
  last `import` (QML) or after `.pragma library` (JS);
  `VoiceRecorderModel.js` has no pragma → `.import "I18n.js" as I18n` on line 1.
  Labels here are separate from stored values (`value:` vs `label:`), so no
  setting value is translated.
- Manual: PresenceModel `day === "Today"` → `day === I18n.t("Today") ?
  I18n.t("today") …`; MessageBubble quoted sender shown via
  `I18n.t(...)` and the accent check accepts "You" or `I18n.t("You")`.
- core.py: constants after `NOTIFY_APP_ICON`: `_FRENCH` (LC_ALL/LC_MESSAGES/LANG
  startswith fr), `NOTIFY_GENERIC_BODY`, `NOTIFY_OPEN_ACTION`; used in
  `_deliver_notification` (summary/body, --action) and `notify-open`
  (`safe_command`).
- Not changed: ids/values ("all", "unread", states), keyboard shortcut strings,
  demo sample messages, emoji keywords, NOTIFY_MEDIA_LABELS (popups are
  generic anyway). Upstream test_backend asserts English popup text; run it
  with LANG=C.UTF-8.

## Re-apply notes

`omarchy-restart-shell` (hot reload is stale), then
`omarchy-shell io.github.moizibnyousaf.omawhatsapp openApp '{}'` and grim only
the top ~120 px of the window (chat content is private): title "Discussions",
search "Rechercher", tabs "Toutes / Non lues / À répondre". Close with
`closeApp` (no argument). No new errors in journalctl (the
"parseJson of null" warning at shell restart predates this).
