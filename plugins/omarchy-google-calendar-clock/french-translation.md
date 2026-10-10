---
id: french-translation
plugin: omarchy-google-calendar-clock
title: Clock and calendar panel in French
bootstrapped: false
enabled: true
applied:
  tree: ccc77be9aac9cba8
  commit: bade88e
  at: 2026-10-08T21:36:41Z
  version: 0.1.10
  source: ""
files:
  - I18n.js
  - Panel.qml
  - BarWidget.qml
---

# Clock and calendar panel in French

## Goal

With the system locale in French, the bar clock shows French day/month names
("jeu. 8 oct. 23:35"), and the calendar panel is in French: header date
("8 octobre"), weekday row (LUN…DIM, no trailing dot), week column "S", month
title, agenda date ("JEUDI 8 OCTOBRE"), event editor, settings, sync messages,
tooltips and event notifications. With a non-French locale everything stays
English as upstream.

## Why / decisions

User is French-speaking; the rest of Omarchy was translated 2026-10-08 via
imnos.language + sbelcl l10n forks, which do not cover this third-party clock.
A plugin-local dictionary (not ~/.config/omarchy/locales/fr.json) keeps it
self-contained. Language is read from `Qt.locale().name` (the shell runs
with LANG=fr_FR.UTF-8). Repeat-option initials became J/S/M/A.

## Where to look

- `BarWidget.qml` `formatted(date)`
- `Panel.qml`: `labelLocale`, day-name header function, the header /
  month / agenda `Qt.formatDate` calls, `eventRepeatOptions`,
  `mutationTargetLabel`, delete/notify/lastPull helpers, every `text:`,
  `tooltipText:`, `placeholderText:` and `calendarSyncMessage =` literal.

## Prior art

Captured against version 0.1.10 (`bade88e`).

- New `I18n.js` (`.pragma library`): `fr` map keyed by exact English
  strings, `t(source, ...args)` with %1/%2, active when `Qt.locale().name`
  starts with "fr"; `shortDay(locale, weekday)` strips the trailing dot. Also
  holds Qt date patterns "MMMM d"→"d MMMM", "dddd, MMMM d"→"dddd d MMMM".
- `BarWidget.qml`: `Qt.formatDateTime(date, fmt)` →
  `date.toLocaleString(Qt.locale(), fmt)` (formatDateTime ignores locale).
- `Panel.qml`: `import "I18n.js" as I18n`; `labelLocale: Qt.locale("en_US")`
  → `Qt.locale()`; `Qt.formatDate(x, f)` → `x.toLocaleDateString(Qt.locale(), f)`
  (pattern through `I18n.t` for "MMMM d" and "dddd, MMMM d");
  `"Last pull: " + Qt.formatDateTime(...)` → `I18n.t("Last pull: %1", date.toLocaleString(...))`;
  concatenations turned into %1 keys: "Click again to confirm deleting %1",
  "Deleted %1 locally — …", "Updated %1 locally — …", " at %1",
  "Start weeks on %1", "Add local event on %1", "Repeat %1".
  All other literals wrapped mechanically: `"X"` → `I18n.t("X")` for every
  key of the map (131 sites), skipping `===`/`!==` comparisons. `text: "W"` and
  repeat `icon: "D"/"W"/"Y"` also wrapped.
- Not changed: logic values ("none", "daily", "FREQ=…", authMode strings),
  "HH:MM" placeholder, keyboard shortcuts (t/w), Google error output passed
  through from helpers, `setup`/`uninstall` scripts.

## Re-apply notes

Bar clock shows French abbreviations (e.g. "jeu. 8 oct."). Open the panel
(`omarchy-shell shell toggle omarchy-google-calendar-clock`): big date
"8 octobre", weekday row LUN MAR MER JEU VEN SAM DIM, week column "S",
"OCTOBRE 2026", agenda header "JEUDI 8 OCTOBRE". Hot reload serves stale QML;
use omarchy-restart-shell before checking. No new errors for this plugin in
`journalctl --user`.
