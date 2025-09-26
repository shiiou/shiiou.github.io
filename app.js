// ——— Manifest ———
const IMAGES = [
  {src: "https://media.discordapp.net/attachments/1379856264674410637/1379856884621774959/Tokyo_pearl_by_shiiou_modified.png?ex=68d7659d&is=68d6141d&hm=428e0d11828a1a122d298e054e6741362e87b1f4c8bcf39761fdc8afc7322c85", width:1600, height:1066, title:"Tokyo Pearl", tags:["lapdance"], caption:" vrchat , 2025"},
];

const $ = sel => document.querySelector(sel);
const gallery = $('#gallery');
const filters = $('#filters');
const year = $('#year'); year.textContent = new Date().getFullYear();

const allTags = [...new Set(IMAGES.flatMap(p => p.tags))].sort();

let activeTag = 'all';
function renderChips(){
  const base = [{label:'All', value:'all'}].concat(allTags.map(t => ({label:`#${t}`, value:t})));
  filters.innerHTML = base.map(btn => `<button class="chip" aria-pressed="${activeTag===btn.value}" data-value="${btn.value}">${btn.label}</button>`).join('');
  filters.querySelectorAll('.chip').forEach(b => b.addEventListener('click', () => {activeTag=b.dataset.value; renderChips(); renderGrid();}));
}

function renderGrid(){
  const list = activeTag==='all' ? IMAGES : IMAGES.filter(p=>p.tags.includes(activeTag));
  if(!list.length){
    gallery.setAttribute('aria-busy','false');
    gallery.innerHTML = `<p style="grid-column:1/-1;color:var(--muted)">Aucune photo n'a été publier dans le manifeste JS.</p>`;
    return;
  }
  gallery.innerHTML = list.map((p,i) => {
    const ratio = (p.height/p.width*100).toFixed(2);

    return `
      <figure class="tile" data-idx="${i}" data-src="${p.src}" data-title="${p.title}" data-caption="${p.caption}">
        <div style="position:relative;aspect-ratio:${p.width}/${p.height}">
          <img src="${p.src}"
               alt="${p.title}"
               width="${p.width}" height="${p.height}"
               loading="lazy" />
        </div>
      </figure>`
  }).join('');

  gallery.querySelectorAll('.tile').forEach((tile,idx)=>{
    tile.addEventListener('click', () => openLightbox(list, idx));
  });
  gallery.setAttribute('aria-busy','false');
}

const dlg = document.getElementById('lightbox');
const lbImg = document.getElementById('lbImg');
const lbTitle = document.getElementById('lbTitle');
const lbCaption = document.getElementById('lbCaption');
const lbDownload = document.getElementById('download');
const btnPrev = document.getElementById('prev');
const btnNext = document.getElementById('next');
const btnClose = document.getElementById('close');

let lbList = [];
let lbIndex = 0;

function openLightbox(list, index){
  lbList = list; lbIndex = index;
  updateLightbox();
  dlg.showModal();
}

function updateLightbox(){
  const p = lbList[lbIndex];
  lbImg.src = p.src; lbImg.width = p.width; lbImg.height=p.height; lbImg.alt = p.title;
  lbTitle.textContent = p.title;
  lbCaption.textContent = p.caption || '';
  lbDownload.href = p.src;
}

function nav(delta){
  lbIndex = (lbIndex + delta + lbList.length) % lbList.length;
  updateLightbox();
}

btnPrev.addEventListener('click', ()=>nav(-1));
btnNext.addEventListener('click', ()=>nav(1));
btnClose.addEventListener('click', ()=>dlg.close());
window.addEventListener('keydown', (e)=>{
  if(!dlg.open) return;
  if(e.key==='Escape') dlg.close();
  if(e.key==='ArrowRight') nav(1);
  if(e.key==='ArrowLeft') nav(-1);
});

renderChips();
renderGrid();
  
