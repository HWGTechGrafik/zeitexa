// Zeitexa - Service Worker fuer den Offline-Betrieb.
//
// Warum ein eigener: Flutter hat seinen eingebauten Service Worker
// abgekuendigt. Seit Flutter 3.44 ist das erzeugte
// flutter_service_worker.js nur noch ein Stummel, der sich beim Aktivieren
// selbst wieder abmeldet. Die PWA hatte damit gar keinen Vorrat mehr - im
// Flugmodus kam nur noch Safaris "keine Internetverbindung".
//
// Der Cache-Name und die Dateiliste unten werden beim Build von
// tools/release/baue_web.ps1 zwischen die Marker geschrieben. Ohne diesen
// Schritt (flutter run, Handbuild) haelt sich der Worker komplett heraus.

'use strict';

// >>> BUILD-ANFANG <<<
const CACHE_NAME = 'zeitexa-1.26.1-a7b222c6';
const PRECACHE = [
  './',
  'assets/AssetManifest.bin',
  'assets/AssetManifest.bin.json',
  'assets/assets/branding/zeitexa-app-icon.svg',
  'assets/assets/branding/zeitexa-mono-ink.svg',
  'assets/assets/branding/zeitexa-mono-white.svg',
  'assets/assets/branding/zeitexa-primary.svg',
  'assets/assets/branding/zeitexa-reversed.svg',
  'assets/assets/fonts/Inter-Bold.ttf',
  'assets/assets/fonts/Inter-Medium.ttf',
  'assets/assets/fonts/Inter-Regular.ttf',
  'assets/assets/fonts/Inter-SemiBold.ttf',
  'assets/assets/fonts/Roboto-Bold.ttf',
  'assets/assets/fonts/Roboto-Regular.ttf',
  'assets/assets/zeitexa_logo.png',
  'assets/FontManifest.json',
  'assets/fonts/MaterialIcons-Regular.otf',
  'assets/NOTICES',
  'assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
  'assets/shaders/ink_sparkle.frag',
  'assets/shaders/stretch_effect.frag',
  'canvaskit/canvaskit.js',
  'canvaskit/canvaskit.wasm',
  'canvaskit/chromium/canvaskit.js',
  'canvaskit/chromium/canvaskit.wasm',
  'drift_worker.js',
  'favicon.png',
  'flutter.js',
  'flutter_bootstrap.js',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
  'icons/Icon-maskable-192.png',
  'icons/Icon-maskable-512.png',
  'index.html',
  'main.dart.js',
  'manifest.json',
  'splash/img/dark-1x.png',
  'splash/img/dark-2x.png',
  'splash/img/dark-3x.png',
  'splash/img/dark-4x.png',
  'splash/img/light-1x.png',
  'splash/img/light-2x.png',
  'splash/img/light-3x.png',
  'splash/img/light-4x.png',
  'sqlite3.wasm',
];
// >>> BUILD-ENDE <<<

const AKTIV = CACHE_NAME !== 'zeitexa-entwicklung';

// Wie viele Dateien gleichzeitig geholt werden. Alles auf einmal bringt
// iOS bei ~20 MB ins Straucheln, eine nach der anderen dauert zu lang.
const GLEICHZEITIG = 6;

self.addEventListener('install', (event) => {
  if (!AKTIV) return;
  event.waitUntil(vorratAnlegen());
  // Bewusst KEIN skipWaiting: eine laufende Sitzung soll nicht mitten im
  // Betrieb halb auf neue Dateien umgestellt werden. Der neue Worker
  // uebernimmt beim naechsten Kaltstart - oder sofort ueber "Jetzt laden"
  // in der Update-Leiste (lib/logic/update_pruefung.dart), die Worker und
  // Caches wegraeumt und neu laedt.
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    // Vorraete frueherer Versionen wegwerfen - sonst waechst der Speicher
    // mit jeder Auslieferung um die volle App.
    const namen = await caches.keys();
    await Promise.all(
      namen
        .filter((name) => name.startsWith('zeitexa-') && name !== CACHE_NAME)
        .map((name) => caches.delete(name)),
    );
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (event) => {
  if (!AKTIV) return;

  const anfrage = event.request;
  if (anfrage.method !== 'GET') return;

  const adresse = new URL(anfrage.url);
  // Fremde Adressen fasst der Worker nie an.
  if (adresse.origin !== self.location.origin) return;
  // version.json ist die Update-Pruefung: die will ausdruecklich den Server
  // fragen und nicht den Vorrat, den sie gerade pruefen soll.
  if (adresse.pathname.endsWith('/version.json')) return;

  if (anfrage.mode === 'navigate') {
    event.respondWith(startseiteLiefern(anfrage));
    return;
  }
  event.respondWith(dateiLiefern(anfrage));
});

/// Alle Dateien der Auslieferung in den Vorrat holen.
async function vorratAnlegen() {
  const vorrat = await caches.open(CACHE_NAME);
  for (let i = 0; i < PRECACHE.length; i += GLEICHZEITIG) {
    const haeppchen = PRECACHE.slice(i, i + GLEICHZEITIG);
    await Promise.all(haeppchen.map((adresse) => holenUndAblegen(vorrat, adresse)));
  }
}

async function holenUndAblegen(vorrat, adresse) {
  // cache: 'reload' geht am HTTP-Zwischenspeicher des Browsers vorbei -
  // sonst landet nach einem Update womoeglich die alte Datei im Vorrat.
  const antwort = await fetch(new Request(adresse, { cache: 'reload' }));
  if (!antwort.ok) {
    throw new Error('Zeitexa: ' + adresse + ' nicht ladbar (' + antwort.status + ')');
  }
  await vorrat.put(adresse, antwort);
}

/// Jede Navigation beantwortet die gespeicherte Startseite. Genau das fehlte
/// bisher: ohne Netz kam der Browser nie bis zur App.
async function startseiteLiefern(anfrage) {
  const vorrat = await caches.open(CACHE_NAME);
  const start = await vorrat.match('./');
  if (start) return start;
  try {
    return await fetch(anfrage);
  } catch (_) {
    return new Response(
      'Zeitexa ist auf diesem Geraet noch nicht vollstaendig gespeichert. '
      + 'Bitte einmal mit Internetverbindung oeffnen.',
      { status: 503, headers: { 'Content-Type': 'text/plain; charset=utf-8' } },
    );
  }
}

/// Alles andere: erst der Vorrat, dann das Netz. Was frisch aus dem Netz
/// kommt, wandert mit in den Vorrat - so sind auch nachgeladene Brocken
/// beim naechsten Mal offline da.
async function dateiLiefern(anfrage) {
  const vorrat = await caches.open(CACHE_NAME);
  const gespeichert = await vorrat.match(anfrage, { ignoreSearch: true });
  if (gespeichert) return gespeichert;
  try {
    const antwort = await fetch(anfrage);
    if (antwort && antwort.ok && antwort.type === 'basic') {
      await vorrat.put(anfrage, antwort.clone());
    }
    return antwort;
  } catch (_) {
    return new Response('', { status: 504, statusText: 'Offline' });
  }
}
