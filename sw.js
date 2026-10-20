// Service worker solo de la demo (no toca la caché de la app real)
const CACHE='gyg-demo-v2';
const BASE=['./','./index.html','./manifest.webmanifest','./icon-180.png','./icon-192.png','./icon-512.png'];
self.addEventListener('install',e=>{e.waitUntil(caches.open(CACHE).then(c=>c.addAll(BASE)));self.skipWaiting();});
self.addEventListener('activate',e=>e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k.startsWith('gyg-demo')&&k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim())));
self.addEventListener('fetch',e=>{if(e.request.method!=='GET')return;const u=new URL(e.request.url);
  if(/fonts\.googleapis\.com|fonts\.gstatic\.com|cdn\.jsdelivr\.net/.test(u.hostname)){e.respondWith(caches.match(e.request).then(c=>c||fetch(e.request).then(r=>{const k=r.clone();caches.open(CACHE).then(x=>x.put(e.request,k));return r;})));return;}
  if(u.origin!==location.origin)return;
  e.respondWith(fetch(e.request).then(r=>{const k=r.clone();caches.open(CACHE).then(x=>x.put(e.request,k));return r;}).catch(()=>caches.match(e.request)));});
