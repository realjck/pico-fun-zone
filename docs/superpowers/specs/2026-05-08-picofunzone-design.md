# Pico Fun Zone — Design Spec

**Date:** 2026-05-08

## Overview

Landing page Vanilla JS pour présenter les jeux Pico-8. La liste des jeux est définie dans `index.js` (`GAME_LIST`), les métadonnées de chaque jeu sont lues depuis leur `readme.md` local. Page statique, aucun serveur requis, hébergée sur GitHub Pages.

## Architecture

Trois fichiers de travail :

| Fichier | Rôle |
|---|---|
| `index.html` | Squelette HTML statique |
| `_assets/css/style.css` | Tous les styles |
| `_assets/js/app.js` | Fetch readmes, DOM dynamique, parallaxe |

`index.js` est inclus en `<script>` avant `app.js` pour exposer `GAME_LIST` globalement.

## Sections

### Header — Banner parallaxe

- Conteneur `#banner` en `position: relative`, hauteur fixe (~380px), `overflow: hidden`
- 3 images (`banner_layer1.png`, `banner_layer2.png`, `banner_layer3.png`) positionnées en `absolute` et empilées
- Titre en overlay : `"Real Burger's"` (petit, au-dessus) + `"Pico Fun Zone"` (grand)
- Parallaxe : listener `scroll` → `transform: translateY(scrollY * factor)` sur chaque layer (facteurs distincts, ex. 0.1 / 0.3 / 0.5)

### Sections jeux

Générées dynamiquement depuis `GAME_LIST`. Pour chaque entrée `[dirName, color]` :

1. `fetch("${dirName}/readme.md")` → texte brut
2. Parsing par index de lignes :
   - `lines[0]` → titre (strip `# `)
   - `lines[2]` → URL image (regex `\(([^)]+)\)`) → préfixée par `"${dirName}/"` (remplace `./`)
   - `lines[6]` → texte about (rendu via `marked.parse()`)
3. HTML produit par section :
   - `background-color: color`
   - Layout flex : image à gauche (~200px), titre + about + bouton à droite
   - Bouton `<a href="./${dirName}/index.html" target="_blank" class="btn-play">Click to Play</a>` — couleur `#27acf9`

Toutes les fetches sont lancées en parallèle via `Promise.all`, puis les sections sont insérées dans l'ordre de `GAME_LIST`.

### Footer

```
Made by 'Real' JCK © 2026 — Games hosted on GitHub Pages — Contact Discord 'Real6235'
```

L'année est injectée via JS : `new Date().getFullYear()`.

## Points techniques

- **Fichier à renommer** : `_assets/js/app.s` → `_assets/js/app.js` (extension incorrecte)
- **marked.js** : inclus depuis `_assets/libs/marked/marked.min.js`, utilisé uniquement pour le rendu du texte about
- **Ordre des sections** : respecte l'ordre de `GAME_LIST`, pas de tri
- **Erreurs de fetch** : si un readme est absent, la section est silencieusement ignorée (log console uniquement)
- **Responsive** : non requis (page simple de présentation)
