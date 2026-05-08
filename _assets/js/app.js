document.getElementById('year').textContent = new Date().getFullYear();

const layer1 = document.getElementById('layer1');
const layer2 = document.getElementById('layer2');

window.addEventListener('scroll', () => {
  const y = window.scrollY;
  layer1.style.transform = `translateY(${y * 0.5}px)`;
  layer2.style.transform = `translateY(${y * 0.3}px)`;
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
    const imgMatch = lines[2].match(/\]\(([^)]+)\)/);
    const imgSrc = imgMatch ? `${dirName}/${imgMatch[1].replace('./', '')}` : '';
    const about = lines[6];
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
