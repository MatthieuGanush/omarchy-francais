#!/usr/bin/env bash
# Omarchy en français : langue du système, menus, panneaux de la barre,
# dossiers utilisateur, plugins tiers et applis (Claude Code, Voxtype).
#
# Rien n'est bloquant : une étape qui échoue est notée, le script continue et
# affiche à la fin ce qui n'a pas marché. Il peut être relancé autant de fois
# que nécessaire (après une mise à jour d'Omarchy par exemple).

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LOCALE="fr_FR.UTF-8"
PLUGINS="$HOME/.config/omarchy/plugins"
RECORDS="$HOME/.config/omarchy/plugin-malleability"
SHELL_JSON="$HOME/.config/omarchy/shell.json"
LANG_ID="imnos.language"
LANG_REPO="https://github.com/sbelcl/omarchy-language.git"
LANG_DIR="$PLUGINS/$LANG_ID"
PANELS=(
  "https://github.com/sbelcl/omarchy-power-l10n.git sbelcl.power"
  "https://github.com/sbelcl/omarchy-audio-l10n.git sbelcl.audio"
  "https://github.com/sbelcl/omarchy-bluetooth-l10n.git sbelcl.bluetooth"
  "https://github.com/sbelcl/omarchy-weather-l10n.git sbelcl.weather"
  "https://github.com/sbelcl/omarchy-monitor-l10n.git sbelcl.monitor"
  "https://github.com/sbelcl/omarchy-agents-l10n.git sbelcl.agents"
  "https://github.com/sbelcl/omarchy-tray-l10n.git sbelcl.tray"
  "https://github.com/sbelcl/omarchy-indicators-l10n.git sbelcl.indicators"
  "https://github.com/sbelcl/omarchy-system-update-l10n.git sbelcl.system-update"
  "https://github.com/sbelcl/omarchy-reminders-l10n.git sbelcl.reminders"
  "https://github.com/sbelcl/omarchy-network-l10n.git sbelcl.network"
  "https://github.com/sbelcl/omarchy-clock-l10n.git sbelcl.clock"
)
# Plugins tiers dont on a traduit l'interface (sautés s'ils ne sont pas installés)
TIERS=(omarchy-google-calendar-clock io.github.jeremylanger.omaspotify io.github.moizibnyousaf.omawhatsapp)

say() { printf '\n\033[1m%s\033[0m\n' "$*"; }
note() { printf '  %s\n' "$*"; }
problems=()
problem() { problems+=("$1"); note "⚠ $1"; }
has() { command -v "$1" >/dev/null 2>&1; }

plugin_enabled() {
  omarchy plugin list --json 2>/dev/null | jq -e --arg id "$1" 'any(.[]; .id == $id and .enabled)' >/dev/null
}
in_bar() {
  jq -e --arg id "$1" '[.bar.layout[]?[]?.id] | index($id) != null' "$SHELL_JSON" >/dev/null 2>&1
}

if ! has omarchy; then
  echo "Ce script est fait pour Omarchy (commande « omarchy » introuvable)." >&2
  exit 1
fi

# Dépôt à jour (sans conséquence si hors ligne)
git -C "$REPO" pull --ff-only -q 2>/dev/null || true

# ---------------------------------------------------------------------------
say "1/7  Langue du système ($LOCALE)"
if ! locale -a 2>/dev/null | grep -qi '^fr_FR\.utf-\?8$'; then
  note "génération de la locale (mot de passe demandé)"
  if sudo sed -i 's/^#\s*\(fr_FR\.UTF-8 UTF-8\)/\1/' /etc/locale.gen && sudo locale-gen >/dev/null; then
    note "locale générée"
  else
    problem "générer la locale fr_FR.UTF-8 (sudo locale-gen)"
  fi
fi
current=$(localectl status 2>/dev/null | sed -n 's/.*LANG=\([^ ]*\).*/\1/p' | head -1)
if [[ $current == "$LOCALE" ]]; then
  note "déjà en français"
elif localectl set-locale "LANG=$LOCALE"; then
  note "langue réglée (prise en compte à la prochaine connexion)"
else
  problem "régler la langue du système (localectl set-locale LANG=$LOCALE)"
fi

# ---------------------------------------------------------------------------
say "2/7  Plugin Language + traduction française"
if [[ -d $LANG_DIR ]]; then
  note "déjà installé"
else
  # Sans --enable : pas besoin de son icône « FR » dans la barre, la langue
  # se change via le menu Omarchy → Mettre à jour → Langue.
  omarchy plugin add "$LANG_REPO" --yes >/dev/null 2>&1
fi
if [[ -d $LANG_DIR ]]; then
  mkdir -p "$LANG_DIR/translations" "$LANG_DIR/locales"
  cp "$REPO/francais/fr_FR.tsv" "$LANG_DIR/translations/fr_FR.tsv"
  cp "$REPO/francais/fr.json" "$LANG_DIR/locales/fr.json"
  note "fichiers fr copiés dans le plugin"
else
  problem "installer le plugin Language depuis $LANG_REPO (réseau ?)"
fi

# ---------------------------------------------------------------------------
say "3/7  Panneaux traduits de la barre"
# L'horloge-calendrier Google remplace déjà l'horloge d'Omarchy : dans ce cas
# pas besoin de l'horloge traduite de sbelcl.
skip_clock=0
[[ -d $PLUGINS/omarchy-google-calendar-clock ]] && skip_clock=1
in_bar omarchy-google-calendar-clock && skip_clock=1
to_enable=()
for entry in "${PANELS[@]}"; do
  read -r url id <<<"$entry"
  if [[ $id == sbelcl.clock ]] && ((skip_clock)); then
    note "$id ignoré (l'horloge-calendrier Google prend sa place)"
    continue
  fi
  if [[ ! -d $PLUGINS/$id ]]; then
    omarchy plugin add "$url" --yes >/dev/null 2>&1
    [[ -d $PLUGINS/$id ]] || { problem "installer $id ($url)"; continue; }
    note "$id installé"
  fi
  plugin_enabled "$id" || to_enable+=("$id")
done
if ((${#to_enable[@]})); then
  # Chaque panneau déclare clonedFrom : en l'activant, le shell lui donne la
  # place du panneau d'origine dans la barre et désactive ce dernier.
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
  for id in "${to_enable[@]}"; do
    if omarchy plugin enable "$id" >/dev/null 2>&1; then
      note "$id activé"
    else
      problem "activer $id (relancer le script après « omarchy-restart-shell »)"
    fi
  done
else
  note "tous déjà actifs"
fi

# ---------------------------------------------------------------------------
say "4/7  Menus et catalogue"
if [[ -x $LANG_DIR/menu-translate ]]; then
  if "$LANG_DIR/menu-translate" apply fr_FR >/dev/null; then
    note "menu Omarchy : $("$LANG_DIR/menu-translate" status)"
  else
    problem "traduire le menu Omarchy"
  fi
  if [[ -f $HOME/.config/hypr/bindings.lua ]]; then
    if grep -q "imnos.language/menu-keybindings" "$HOME/.config/hypr/bindings.lua"; then
      note "Super+K déjà traduit"
    elif "$LANG_DIR/menu-keybindings" bind >/dev/null; then
      note "Super+K traduit"
    else
      problem "traduire le menu Super+K"
    fi
  fi
  catalog="$HOME/.config/omarchy/locales/fr.json"
  if cmp -s "$catalog" "$REPO/francais/fr.json"; then
    note "catalogue des panneaux à jour"
  else
    # refresh garde une copie .bak si le fichier existait déjà
    if [[ -f $catalog ]]; then
      "$LANG_DIR/catalog" refresh "$LOCALE" >/dev/null
    else
      "$LANG_DIR/catalog" install "$LOCALE" >/dev/null
    fi
    if cmp -s "$catalog" "$REPO/francais/fr.json"; then
      note "catalogue des panneaux installé"
    else
      problem "installer le catalogue $catalog"
    fi
  fi
else
  problem "menus non traduits : le plugin Language manque (étape 2)"
fi

# ---------------------------------------------------------------------------
say "5/7  Dossiers utilisateur en français"
# On ne déplace que si le dossier français n'existe pas encore ; si les deux
# existent, on laisse tout en place et on le signale.
pairs=("Downloads:Téléchargements" "Music:Musique" "Pictures:Images" "Videos:Vidéos" "Projects:Projets")
for pair in "${pairs[@]}"; do
  en="$HOME/${pair%%:*}" fr="$HOME/${pair##*:}"
  if [[ -L $fr || -d $fr ]]; then
    [[ -d $en && ! -L $en ]] && note "~/${pair%%:*} et ~/${pair##*:} existent tous les deux : à fusionner à la main"
  elif [[ -d $en && ! -L $en ]]; then
    mv "$en" "$fr" && note "~/${pair%%:*} → ~/${pair##*:}"
  else
    mkdir -p "$fr"
  fi
done
mkdir -p "$HOME/Documents" "$HOME/.config"
if ! cmp -s "$HOME/.config/user-dirs.dirs" "$REPO/francais/user-dirs.dirs"; then
  [[ -f $HOME/.config/user-dirs.dirs ]] && cp -n "$HOME/.config/user-dirs.dirs" "$HOME/.config/user-dirs.dirs.avant-fr"
  cp "$REPO/francais/user-dirs.dirs" "$HOME/.config/user-dirs.dirs"
  note "user-dirs.dirs écrit (ancien gardé en user-dirs.dirs.avant-fr)"
else
  note "déjà en place"
fi
echo "fr_FR" >"$HOME/.config/user-dirs.locale"

# ---------------------------------------------------------------------------
say "6/7  Plugins tiers installés"
# Le patch est fait pour une version précise du plugin. Même version → appliqué.
# Autre version → la fiche est déposée dans Plugin Malleability (bouton
# « Re-apply »). Plugin absent → rien à faire.
for id in "${TIERS[@]}"; do
  dir="$REPO/plugins/$id" target="$PLUGINS/$id"
  if [[ ! -d $target ]]; then
    note "$id : pas installé, sauté"
    continue
  fi
  if [[ ! -d $target/.git ]]; then
    problem "$id : installé sans git, traduction non appliquée"
    continue
  fi
  if git -C "$target" apply --reverse --check "$dir/francais.patch" >/dev/null 2>&1; then
    note "$id : déjà traduit"
  elif [[ -n $(find "$target" -name I18n.js -print -quit) ]]; then
    # Traduit avec d'autres retouches en plus (omarchy-perso par exemple)
    note "$id : déjà traduit"
  elif [[ $(git -C "$target" rev-parse HEAD 2>/dev/null) == "$(cat "$dir/commit")" ]] &&
    git -C "$target" apply "$dir/francais.patch" 2>/dev/null; then
    note "$id : traduit"
  elif [[ -d $PLUGINS/djschnei21.plugin-malleability ]]; then
    mkdir -p "$RECORDS/$id"
    cp -n "$dir"/*.md "$RECORDS/$id/" 2>/dev/null
    problem "$id : version $(jq -r .version "$target/manifest.json" 2>/dev/null) ≠ $(cat "$dir/version"), fiche déposée dans Plugin Malleability → cliquer « Re-apply »"
  else
    problem "$id : version $(jq -r .version "$target/manifest.json" 2>/dev/null) ≠ $(cat "$dir/version") (ou déjà modifié), traduction non appliquée"
  fi
done

# ---------------------------------------------------------------------------
say "7/7  Applis"
if has claude || [[ -d $HOME/.claude ]]; then
  mkdir -p "$HOME/.claude"
  settings="$HOME/.claude/settings.json"
  [[ -s $settings ]] || echo '{}' >"$settings"
  if tmp=$(jq '.language = "french"' "$settings") && printf '%s\n' "$tmp" >"$settings"; then
    note "Claude Code : réponses en français"
  else
    problem "Claude Code : régler la langue dans $settings"
  fi
  if ! grep -q '^# Langue' "$HOME/.claude/CLAUDE.md" 2>/dev/null; then
    [[ -s $HOME/.claude/CLAUDE.md ]] && echo >>"$HOME/.claude/CLAUDE.md"
    cat "$REPO/francais/CLAUDE.md" >>"$HOME/.claude/CLAUDE.md"
    note "Claude Code : consigne ajoutée à ~/.claude/CLAUDE.md"
  fi
else
  note "Claude Code : pas installé, sauté"
fi
if has voxtype; then
  # Dictée en français avec le modèle « small » (les modèles .en ne parlent qu'anglais)
  if voxtype setup --download --model small --quiet >/dev/null 2>&1 &&
    voxtype config set whisper.model small >/dev/null 2>&1 &&
    voxtype config set whisper.language fr >/dev/null 2>&1; then
    systemctl --user try-restart voxtype.service >/dev/null 2>&1 || true
    note "Voxtype : dictée en français (modèle small)"
  else
    problem "Voxtype : passer en français (voxtype config set whisper.language fr)"
  fi
else
  note "Voxtype : pas installé, sauté"
fi

# ---------------------------------------------------------------------------
omarchy-restart-shell >/dev/null 2>&1 || true

say "Terminé"
if ((${#problems[@]})); then
  echo "Ce qui n'a pas marché (le reste est fait) :"
  for p in "${problems[@]}"; do echo "  - $p"; done
  echo "On peut relancer le script après avoir corrigé : il saute ce qui est déjà fait."
fi
echo "Se déconnecter puis se reconnecter pour que tout passe en français."
