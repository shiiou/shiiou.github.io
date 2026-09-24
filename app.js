const grid=document.querySelector('#grid');
const count=document.querySelector('#count');
const viewer=document.querySelector('#viewer');
const viewerMedia=document.querySelector('#viewer-media');
let media=[];
let filter='all';
document.querySelector('#year').textContent=new Date().getFullYear();
function empty(title,body){
  grid.replaceChildren();
  const box=document.createElement('div');box.className='empty';
  const inner=document.createElement('div');const mark=document.createElement('div');mark.className='empty-mark';mark.textContent='✦';
  const heading=document.createElement('h2');heading.textContent=title;
  const text=document.createElement('p');text.textContent=body;
  inner.append(mark,heading,text);box.append(inner);grid.append(box);
}
function render(){
  const shown=media.filter(item=>filter==='all'||item.type===filter);
  count.textContent=shown.length+' '+(shown.length===1?'média':'médias');
  if(!shown.length){empty(media.length?'Aucun média dans cette catégorie':'La galerie attend tes créations',media.length?'Choisis un autre filtre pour voir la galerie.':'Ajoute tes liens publics dans media.json pour afficher tes photos et vidéos.');return}
  grid.replaceChildren();
  for(const item of shown){
    const card=document.createElement('button');card.type='button';card.className='tile';card.setAttribute('aria-label','Ouvrir '+item.title);
    const thumb=document.createElement('span');thumb.className='thumb';
    if(item.type==='image'){
      const img=document.createElement('img');img.src=item.thumbnail||item.url;img.alt=item.title;img.loading='lazy';thumb.append(img);
    }else{
      if(item.thumbnail){const img=document.createElement('img');img.src=item.thumbnail;img.alt='Aperçu de '+item.title;img.loading='lazy';thumb.append(img)}
      else{const preview=document.createElement('video');preview.src=item.url+'#t=0.1';preview.preload='metadata';preview.muted=true;thumb.append(preview)}
      const play=document.createElement('span');play.className='play';play.textContent='▶';thumb.append(play);
    }
    const info=document.createElement('span');info.className='tile-text';
    const title=document.createElement('span');title.className='tile-title';title.textContent=item.title;
    const kind=document.createElement('span');kind.className='tile-kind';kind.textContent=item.type==='image'?'PHOTO':'VIDÉO';
    info.append(title,kind);card.append(thumb,info);card.addEventListener('click',()=>openViewer(item));grid.append(card);
  }
}
function openViewer(item){
  viewerMedia.replaceChildren();document.querySelector('#viewer-title').textContent=item.title;
  let element;
  if(item.type==='image'){element=document.createElement('img');element.alt=item.title}
  else{element=document.createElement('video');element.controls=true;element.autoplay=true;element.playsInline=true}
  element.src=item.url;viewerMedia.append(element);viewer.showModal();
}
function closeViewer(){const video=viewerMedia.querySelector('video');if(video)video.pause();viewer.close();viewerMedia.replaceChildren()}
document.querySelector('#close').addEventListener('click',closeViewer);
viewer.addEventListener('click',event=>{if(event.target===viewer)closeViewer()});
viewer.addEventListener('close',()=>viewerMedia.replaceChildren());
document.querySelectorAll('[data-filter]').forEach(button=>button.addEventListener('click',()=>{
  filter=button.dataset.filter;
  document.querySelectorAll('[data-filter]').forEach(other=>other.setAttribute('aria-pressed',String(other===button)));
  render();
}));
fetch('./media.json',{cache:'no-store'}).then(response=>{if(!response.ok)throw Error('Fichier media.json introuvable.');return response.json()}).then(data=>{
  if(!Array.isArray(data))throw Error('media.json doit contenir une liste de médias.');
  media=data.filter(item=>item&&['image','video'].includes(item.type)&&typeof item.title==='string'&&typeof item.url==='string'&&/^https:\/\//i.test(item.url)&&(!item.thumbnail||/^https:\/\//i.test(item.thumbnail)));
  render();
}).catch(error=>empty('Galerie indisponible',error.message));
