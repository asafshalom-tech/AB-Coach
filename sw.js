const CACHE='ab-coach-studio-v3-2';
const CORE=['./','./index.html','./app.css?v=3.2','./app.js?v=3.2','./manifest.webmanifest','./icon-192.png','./icon-512.png'];
self.addEventListener('install',event=>event.waitUntil(caches.open(CACHE).then(cache=>cache.addAll(CORE)).then(()=>self.skipWaiting())));
self.addEventListener('activate',event=>event.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(key=>key!==CACHE).map(key=>caches.delete(key)))).then(()=>self.clients.claim())));
self.addEventListener('fetch',event=>{let request=event.request;if(request.method!=='GET'||new URL(request.url).origin!==self.location.origin)return;event.respondWith(fetch(request).then(response=>{if(response.ok){let clone=response.clone();caches.open(CACHE).then(cache=>cache.put(request,clone)).catch(()=>{})}return response}).catch(()=>caches.match(request).then(found=>found||caches.match('./index.html'))))});
