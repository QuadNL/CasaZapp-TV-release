# FAQ

**Does CasaZapp TV come with channels?**
No. You need to bring your own.

**My provider allows one connection. Can two people watch?**
Not at the same time. CasaZapp TV counts connections per playlist, preventing you from 
exceeding your provider's limit.

**Does the stream go through my server?**
In the browser, yes: browsers don't allow playing most provider streams directly. The Android app
can play straight from the provider (Settings → Playback), reduces your server's network load.

**Pausing live TV doesn't work.**
This feature requires the server and ffmpeg (which is included in the Docker image). The buffer is written 
to `CACHE_DIR`; check that there's room. It keeps up to two hours and is removed ten minutes after you stop.

**Where are my recordings?**
In `RECORDINGS_DIR` (by default `/data/recordings`), one folder per recording. They play in the
app and the browser, and can be downloaded from there.

**The guide is empty for some channels.**
The guide comes from your provider. Not every provider has one for every channel; channels
without it show "no programme information".

**Can I use it on an iPhone?**
In Safari as a web app, with some limits: a few stream types don't play there. There's no iOS app.

**Is my provider password safe?**
Credentials are never exposed to the client app or the browser.
