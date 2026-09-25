# FAQ

**Does CasaZapp TV come with channels?**
No. It plays the playlist you give it: from a provider you pay for, or a legal free list such as
the ones on iptv-org. Nothing is included and nothing is shared.

**My provider allows one connection. Can two people watch?**
Not at the same time. CasaZapp TV counts the connections per playlist. When they're all in use,
the next device asks whether to take one over; the other device then stops and says who took it.
Under "Active now" on Home you see who's watching what, and can stop a stream from there.

**Does the stream go through my server?**
In the browser, yes: browsers don't allow playing most provider streams directly. The Android app
can play straight from the provider (Settings → Playback), which spares your upload.

**Pausing live TV doesn't work.**
It needs the server and ffmpeg, which is in the image. The buffer is written to `CACHE_DIR`; check
that there's room. It keeps up to two hours and is removed ten minutes after you stop.

**Where are my recordings?**
In `RECORDINGS_DIR` (by default `/data/recordings`), one folder per recording. They play in the
app and the browser, and can be downloaded from there.

**The guide is empty for some channels.**
The guide comes from your provider. Not every provider has one for every channel; channels
without it show "no programme information".

**Can I use it on an iPhone?**
In Safari as a web app, with some limits: a few stream types don't play there. There's no iOS app.

**Is my provider password safe?**
It's stored encrypted in the database, with a key in your own `/data` folder. It never goes to
the app or the browser.
