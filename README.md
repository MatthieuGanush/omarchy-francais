# Omarchy en français

Met [Omarchy](https://omarchy.org) entièrement en français : langue du système,
menus, panneaux de la barre, dossiers personnels, plugins tiers et quelques applis.

## Installer

Dans un terminal :

```bash
git clone https://github.com/MatthieuGanush/omarchy-francais ~/omarchy-francais && ~/omarchy-francais/install.sh
```

Le mot de passe peut être demandé (génération de la langue française). À la fin,
**se déconnecter puis se reconnecter**.

Rien n'est bloquant : si une étape échoue (réseau, plugin absent, version
différente…), le script continue et affiche à la fin la liste de ce qui n'a pas
marché. On peut le relancer autant de fois qu'on veut, il saute ce qui est déjà fait.

## Ce que fait le script

| Étape | Détail |
|---|---|
| **Langue du système** | génère et règle `fr_FR.UTF-8` (dates, applis GTK/Qt…) |
| **Plugin Language** | installe [sbelcl/omarchy-language](https://github.com/sbelcl/omarchy-language) et y ajoute la traduction française (`francais/fr_FR.tsv`, `francais/fr.json`) |
| **Panneaux de la barre** | remplace les panneaux d'Omarchy par leurs versions traduites de sbelcl : alimentation, son, Bluetooth, météo, écrans, agents, zone de notification, indicateurs, mises à jour, rappels, réseau, horloge (sauf si l'horloge-calendrier Google est installée) |
| **Menus** | menu Omarchy et liste des raccourcis (Super+K) en français |
| **Dossiers** | `Downloads` → `Téléchargements`, `Music` → `Musique`, `Pictures` → `Images`, `Videos` → `Vidéos`, `Projects` → `Projets` (si les deux existent, rien n'est déplacé) |
| **Plugins tiers** | traduit l'interface d'[omarchy-google-calendar-clock](https://github.com/NachoRodriguezM/omarchy-google-calendar-clock), [OmaSpotify](https://github.com/jeremylanger/omaspotify) et [OmaWhatsApp](https://github.com/MoizIbnYousaf/Omarchy-Whatsapp) **s'ils sont installés** (sinon sautés) |
| **Applis** | Claude Code répond en français ; dictée Voxtype en français (modèle `small`) — chacun seulement s'il est installé |

### Plugins tiers

Chaque traduction (`plugins/<plugin>/francais.patch`) est faite pour une version
précise du plugin (`version`, `commit`).

- Même version → appliquée directement.
- Autre version → si [Plugin Malleability](https://github.com/djschnei21/omarchy-plugin-malleability)
  est installé, la fiche de traduction y est déposée : ouvrir son panneau et
  cliquer **Re-apply** sur le plugin. Sinon la traduction est simplement sautée.
- Pour OmaSpotify et OmaWhatsApp, `outils/` contient le dictionnaire (`I18n.js`),
  la table anglais → français et `rewrap.py`, qui refait le gros du travail sur
  une nouvelle version.

## Ce qui n'est pas touché

- **Le clavier** : il se choisit à l'installation d'Omarchy (AZERTY = `fr`).
  Pour le changer ensuite : `~/.config/hypr/input.lua`, `kb_layout = "fr"`.
- Les plugins non listés ci-dessus restent en anglais.

## Après une mise à jour d'Omarchy

Si un menu ou un panneau repasse en anglais :

```bash
~/omarchy-francais/install.sh
```

(le script récupère d'abord la dernière version de ce dépôt).

## Remerciements

Le gros du travail de traduction des menus et panneaux vient de
[sbelcl](https://github.com/sbelcl). La traduction française a aussi été proposée
au plugin Language ([PR #25](https://github.com/sbelcl/omarchy-language/pull/25)).
