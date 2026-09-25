// The demo playlist and its guide: made-up channels, one public test video, a guide around today.
// Run it again to move the guide to the current days: node demo/make-demo.mjs
import { writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const here = path.dirname(fileURLToPath(import.meta.url));
const RAW = 'https://raw.githubusercontent.com/QuadNL/CasaZapp-TV-release/main/demo';
// A public test stream made for trying players (Mux, "Big Buck Bunny").
const STREAM = 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';

export const CHANNELS = [
  { id: 'news1', name: 'News 1', group: 'News', color: '#4da3ff', shows: [['Morning News', 60], ['News at Ten', 30], ['The Briefing', 30], ['World Report', 60], ['Headlines', 30], ['Business Today', 30]] },
  { id: 'news2', name: 'News 2', group: 'News', color: '#2ec4c6', shows: [['Newsroom', 60], ['Weather Update', 30], ['Politics Live', 60], ['The Week', 60], ['Headlines', 30]] },
  { id: 'sport1', name: 'Sport 1', group: 'Sport', color: '#3dd68c', shows: [['Match of the Week', 120], ['Goals Round-up', 30], ['Tennis Live', 90], ['Sport Tonight', 60]] },
  { id: 'sport2', name: 'Sport 2', group: 'Sport', color: '#ff4d5e', shows: [['Motor Weekend', 90], ['Basketball', 120], ['Cycling Classics', 90], ['Extra Time', 30]] },
  { id: 'kids', name: 'Kids', group: 'Kids', color: '#ffb547', shows: [['Cartoon Hour', 60], ['Puzzle Club', 30], ['Little Explorers', 30], ['Story Time', 30], ['Animal Friends', 30]] },
  { id: 'cartoon', name: 'Cartoon', group: 'Kids', color: '#ff7ab6', shows: [['Toon Parade', 30], ['Space Rangers', 30], ['The Funny Farm', 30], ['Robot Pals', 30]] },
  { id: 'music', name: 'Music', group: 'Entertainment', color: '#a47bff', shows: [['Top 40', 60], ['Live Sessions', 60], ['Throwback Hits', 60], ['Acoustic Hour', 60]] },
  { id: 'movies', name: 'Movies', group: 'Entertainment', color: '#8793a6', shows: [['The Long Road', 120], ['Night Train', 105], ['Summer House', 95], ['The Heist', 110]] },
  { id: 'comedy', name: 'Comedy', group: 'Entertainment', color: '#ffb547', shows: [['Stand-up Night', 60], ['Sitcom Classics', 30], ['Quiz Show', 45], ['Panel Games', 45]] },
  { id: 'nature', name: 'Nature', group: 'Documentary', color: '#3dd68c', shows: [['Wild Coasts', 60], ['Planet Oceans', 60], ['Forest Life', 45], ['Big Cats', 45]] },
  { id: 'travel', name: 'Travel', group: 'Documentary', color: '#2ec4c6', shows: [['City Breaks', 30], ['Road Trips', 60], ['Island Hopping', 30], ['Food Journeys', 60]] },
  { id: 'weather', name: 'Weather', group: 'News', color: '#4da3ff', shows: [['Weather Now', 15], ['Outlook', 15]] },
];

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const m3u = [`#EXTM3U url-tvg="${RAW}/guide.xml"`];
  for (const c of CHANNELS) {
    m3u.push(`#EXTINF:-1 tvg-id="${c.id}" tvg-logo="${RAW}/logos/${c.id}.png" group-title="${c.group}",${c.name}`, STREAM);
  }
  writeFileSync(path.join(here, 'playlist.m3u'), m3u.join('\n') + '\n');

  // Three days of programmes from yesterday midnight (UTC), each channel repeating its shows.
  const day = 24 * 3600 * 1000;
  const start = new Date(Math.floor(Date.now() / day) * day - day);
  const stamp = (d) => d.toISOString().replace(/[-:T]/g, '').slice(0, 14) + ' +0000';
  const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;');
  const xml = ['<?xml version="1.0" encoding="UTF-8"?>', '<tv generator-info-name="CasaZapp TV demo">'];
  for (const c of CHANNELS) xml.push(`  <channel id="${c.id}"><display-name>${esc(c.name)}</display-name></channel>`);
  for (const c of CHANNELS) {
    let t = start.getTime(), i = 0;
    while (t < start.getTime() + 3 * day) {
      const [title, minutes] = c.shows[i++ % c.shows.length];
      const stop = t + minutes * 60_000;
      xml.push(
        `  <programme start="${stamp(new Date(t))}" stop="${stamp(new Date(stop))}" channel="${c.id}">` +
          `<title>${esc(title)}</title><desc>${esc(`${title} on ${c.name}, a made-up programme for the demo.`)}</desc></programme>`,
      );
      t = stop;
    }
  }
  xml.push('</tv>');
  writeFileSync(path.join(here, 'guide.xml'), xml.join('\n') + '\n');
  console.log(`playlist.m3u: ${CHANNELS.length} channels; guide.xml from ${start.toISOString()}`);
}
