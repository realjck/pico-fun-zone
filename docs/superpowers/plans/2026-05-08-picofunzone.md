# Pico Fun Zone Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Créer la page d'accueil Vanilla JS pour présenter les jeux Pico-8 définis dans `GAME_LIST`.

**Architecture:** Squelette HTML statique + styles CSS + script JS qui fetch les `readme.md` de chaque jeu en parallèle, construit le DOM dynamiquement, et anime le parallaxe sur scroll.

**Tech Stack:** HTML5, CSS3, Vanilla JS (ES2020+), marked v15 (`_assets/libs/marked/marked.min.js`), Google Fonts (Press Start 2P)

---

## File Map

| Fichier | Action | Responsabilité |
|---|---|---|
| `index.html` | Créer | Squelette statique : banner, `<main id="games">`, footer, script tags |
| `_assets/css/style.css` | Créer | Tous les styles : banner, parallaxe, sections jeux, footer |
| `_assets/js/app.js` | Créer | Fetch readmes, parsing, construction DOM, parallaxe scroll |

`index.js` (existant) expose `GAME_LIST` — ne pas modifier.

---

## Task 1 — index.html : squelette statique

**Files:**
- Create: `index.html`

- [ ] **Écrire le fichier `index.html`**

```html
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Pico Fun Zone</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Press+Start+2P&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="_assets/css/style.css">
</head>
<body>

  <header id="banner">
    <img id="layer1" src="_assets/images/banner_layer1.png" alt="">
    <img id="layer2" src="_assets/images/banner_layer2.png" alt="">
    <img id="layer3" src="_assets/images/banner_layer3.png" alt="">
    <div id="banner-title">
      <p>Real Burger's</p>
      <h1>Pico Fun Zone</h1>
    </div>
  </header>

  <main id="games"></main>

  <footer id="footer">
    <p>Made by 'Real' JCK &copy; <span id="year"></span> &mdash; Games hosted on GitHub Pages &mdash; Contact Discord 'Real6235'</p>
  </footer>

  <script src="index.js"></script>
  <script src="_assets/libs/marked/marked.min.js"></script>
  <script src="_assets/js/app.js"></script>

</body>
</html>
```

- [ ] **Ouvrir dans le navigateur et vérifier** que la page charge sans erreur console (le `<main>` sera vide, le banner ne sera pas stylisé — c'est attendu).

- [ ] **Commit**

```bash
git add index.html
git commit -m "feat: add index.html skeleton"
```

---

## Task 2 — style.css : styles globaux et banner

**Files:**
- Modify: `_assets/css/style.css`

- [ ] **Écrire les styles dans `_assets/css/style.css`**

```css
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: sans-serif;
  background: #111;
  color: #fff;
}

/* ── Banner ── */

#banner {
  position: relative;
  height: 380px;
  overflow: hidden;
}

#banner img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 140%;
  object-fit: cover;
  object-position: top;
}

#banner-title {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
  z-index: 10;
  white-space: nowrap;
}

#banner-title p {
  font-family: 'Press Start 2P', monospace;
  font-size: 0.85rem;
  color: #fff;
  text-shadow: 2px 2px 0 #000;
  margin-bottom: 12px;
}

#banner-title h1 {
  font-family: 'Press Start 2P', monospace;
  font-size: 2.5rem;
  color: #fff;
  text-shadow: 3px 3px 0 #000;
}

/* ── Sections jeux ── */

.game-section {
  padding: 48px 64px;
}

.game-content {
  display: flex;
  align-items: center;
  gap: 48px;
  max-width: 900px;
  margin: 0 auto;
}

.game-cover {
  width: 200px;
  height: auto;
  flex-shrink: 0;
  image-rendering: pixelated;
}

.game-info h2 {
  font-family: 'Press Start 2P', monospace;
  font-size: 1.1rem;
  margin-bottom: 16px;
}

.game-about {
  font-size: 0.9rem;
  line-height: 1.7;
  margin-bottom: 24px;
}

.game-about p {
  margin: 0;
}

.btn-play {
  display: inline-block;
  background-color: #27acf9;
  color: #fff;
  padding: 12px 24px;
  text-decoration: none;
  font-family: 'Press Start 2P', monospace;
  font-size: 0.6rem;
  letter-spacing: 0.05em;
}

.btn-play:hover {
  background-color: #1a8fd1;
}

/* ── Footer ── */

#footer {
  background: #111;
  padding: 32px 24px;
  text-align: center;
  font-size: 0.75rem;
  color: #888;
}
```

- [ ] **Recharger dans le navigateur** — le banner doit afficher les 3 images et le titre centré avec la font pixel. Le `<main>` est toujours vide.

- [ ] **Commit**

```bash
git add _assets/css/style.css
git commit -m "feat: add CSS styles (banner, game sections, footer)"
```

---

## Task 3 — app.js : footer year + build game sections

**Files:**
- Modify: `_assets/js/app.js`

- [ ] **Écrire `_assets/js/app.js`**

```js
document.getElementById('year').textContent = new Date().getFullYear();

function buildSection(dirName, color, title, imgSrc, about) {
  const section = document.createElement('section');
  section.className = 'game-section';
  section.style.backgroundColor = color;
  section.innerHTML = `
    <div class="game-content">
      <img class="game-cover" src="${imgSrc}" alt="${title}">
      <div class="game-info">
        <h2>${title}</h2>
        <div class="game-about">${about}</div>
        <a href="./${dirName}/index.html" target="_blank" class="btn-play">Click to Play</a>
      </div>
    </div>
  `;
  return section;
}

async function loadGame([dirName, color]) {
  try {
    const res = await fetch(`${dirName}/readme.md`);
    const text = await res.text();
    const lines = text.split('\n');
    const title = lines[0].replace(/^#\s+/, '');
    const imgMatch = lines[2].match(/\(([^)]+)\)/);
    const imgSrc = imgMatch ? `${dirName}/${imgMatch[1].replace('./', '')}` : '';
    const about = marked.parse(lines[6]);
    return buildSection(dirName, color, title, imgSrc, about);
  } catch (e) {
    console.warn(`Could not load ${dirName}/readme.md`, e);
    return null;
  }
}

async function init() {
  const sections = await Promise.all(GAME_LIST.map(loadGame));
  const main = document.getElementById('games');
  sections.forEach(section => {
    if (section) main.appendChild(section);
  });
}

init();
```

- [ ] **Recharger dans le navigateur** (depuis un serveur local — `fetch` ne fonctionne pas avec `file://`).

  Démarrer un serveur local si besoin :
  ```bash
  # Python
  python -m http.server 8080
  # ou Node
  npx serve .
  ```

  Vérifier :
  - Les sections de jeux s'affichent dans l'ordre de `GAME_LIST`
  - Chaque section a sa couleur de fond
  - L'image de jaquette est visible
  - Le titre est en font pixel
  - Le texte about est présent
  - Le bouton "Click to Play" est bleu `#27acf9`
  - L'année dans le footer est correcte (`2026`)

- [ ] **Commit**

```bash
git add _assets/js/app.js
git commit -m "feat: add JS to build game sections from GAME_LIST + readmes"
```

---

## Task 4 — app.js : parallaxe scroll

**Files:**
- Modify: `_assets/js/app.js`

- [ ] **Ajouter le listener parallaxe dans `app.js`** (après les imports, avant `init()`)

  Ajouter ces lignes juste après la ligne `document.getElementById('year')...` :

```js
const layer1 = document.getElementById('layer1');
const layer2 = document.getElementById('layer2');
const layer3 = document.getElementById('layer3');

window.addEventListener('scroll', () => {
  const y = window.scrollY;
  layer1.style.transform = `translateY(${y * 0.1}px)`;
  layer2.style.transform = `translateY(${y * 0.3}px)`;
  layer3.style.transform = `translateY(${y * 0.5}px)`;
});
```

  Le fichier `app.js` complet après modification :

```js
document.getElementById('year').textContent = new Date().getFullYear();

const layer1 = document.getElementById('layer1');
const layer2 = document.getElementById('layer2');
const layer3 = document.getElementById('layer3');

window.addEventListener('scroll', () => {
  const y = window.scrollY;
  layer1.style.transform = `translateY(${y * 0.1}px)`;
  layer2.style.transform = `translateY(${y * 0.3}px)`;
  layer3.style.transform = `translateY(${y * 0.5}px)`;
});

function buildSection(dirName, color, title, imgSrc, about) {
  const section = document.createElement('section');
  section.className = 'game-section';
  section.style.backgroundColor = color;
  section.innerHTML = `
    <div class="game-content">
      <img class="game-cover" src="${imgSrc}" alt="${title}">
      <div class="game-info">
        <h2>${title}</h2>
        <div class="game-about">${about}</div>
        <a href="./${dirName}/index.html" target="_blank" class="btn-play">Click to Play</a>
      </div>
    </div>
  `;
  return section;
}

async function loadGame([dirName, color]) {
  try {
    const res = await fetch(`${dirName}/readme.md`);
    const text = await res.text();
    const lines = text.split('\n');
    const title = lines[0].replace(/^#\s+/, '');
    const imgMatch = lines[2].match(/\(([^)]+)\)/);
    const imgSrc = imgMatch ? `${dirName}/${imgMatch[1].replace('./', '')}` : '';
    const about = marked.parse(lines[6]);
    return buildSection(dirName, color, title, imgSrc, about);
  } catch (e) {
    console.warn(`Could not load ${dirName}/readme.md`, e);
    return null;
  }
}

async function init() {
  const sections = await Promise.all(GAME_LIST.map(loadGame));
  const main = document.getElementById('games');
  sections.forEach(section => {
    if (section) main.appendChild(section);
  });
}

init();
```

- [ ] **Vérifier dans le navigateur** :
  - Scroller vers le bas : les 3 layers du banner bougent à des vitesses différentes (effet de profondeur)
  - Aucune erreur console

- [ ] **Commit final**

```bash
git add _assets/js/app.js
git commit -m "feat: add parallax scroll effect on banner layers"
```

---

## Self-Review

### Couverture spec
- [x] Banner parallaxe 3 calques — Task 4
- [x] Titre "Real Burger's" + "Pico Fun Zone" — Task 1
- [x] Sections jeux depuis GAME_LIST — Task 3
- [x] Couleur de fond par jeu — Task 3 (`buildSection`)
- [x] Titre depuis `lines[0]` — Task 3 (`loadGame`)
- [x] Image depuis `lines[2]` — Task 3 (`loadGame`)
- [x] Texte about depuis `lines[6]` via `marked.parse` — Task 3 (`loadGame`)
- [x] Bouton "Click to Play" `#27acf9` → `/${dirName}/index.html` `target="_blank"` — Task 3
- [x] Footer avec année dynamique — Task 3
- [x] Marked v15 API : `marked.parse()` — Task 3

### Cohérence des noms
- `layer1/layer2/layer3` — cohérents entre Task 2 (HTML ids) et Task 4 (JS `getElementById`)
- `buildSection` — définie en Task 3, utilisée en Task 3
- `loadGame` — définie et utilisée en Task 3
- `.game-section`, `.game-content`, `.game-cover`, `.game-info`, `.game-about`, `.btn-play` — cohérents entre Task 2 (CSS) et Task 3 (JS)
