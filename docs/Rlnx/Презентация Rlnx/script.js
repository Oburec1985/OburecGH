const slides=[...document.querySelectorAll('.slide')];
const dots=document.querySelector('.dots');
const current=document.querySelector('#current');
const progress=document.querySelector('#progressBar');
slides.forEach((slide,i)=>{const a=document.createElement('a');a.href=`#${slide.id}`;a.setAttribute('aria-label',`${i+1}. ${slide.dataset.label}`);dots.append(a)});
const links=[...dots.children];
let active=0;
function setActive(i){active=i;links.forEach((a,n)=>a.classList.toggle('active',n===i));current.textContent=String(i+1).padStart(2,'0');progress.style.width=`${((i+1)/slides.length)*100}%`}
const observer=new IntersectionObserver(entries=>entries.forEach(e=>{if(e.isIntersecting)setActive(slides.indexOf(e.target))}),{threshold:.58});
slides.forEach(s=>observer.observe(s));
function go(delta){slides[Math.max(0,Math.min(slides.length-1,active+delta))].scrollIntoView({behavior:'smooth'})}
document.querySelector('.prev').addEventListener('click',()=>go(-1));document.querySelector('.next').addEventListener('click',()=>go(1));
document.addEventListener('keydown',e=>{if(['ArrowDown','PageDown',' '].includes(e.key)){e.preventDefault();go(1)}if(['ArrowUp','PageUp'].includes(e.key)){e.preventDefault();go(-1)}if(e.key==='Home')slides[0].scrollIntoView({behavior:'smooth'});if(e.key==='End')slides.at(-1).scrollIntoView({behavior:'smooth'})});
setActive(0);
