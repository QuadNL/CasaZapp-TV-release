# Demo playlist

Fictional channels to try CasaZapp TV without a subscription of your own, and for the screenshots on
the site. Every channel plays the same public test video (Big Buck Bunny, from Mux's test streams);
the guide and the logos are made up.

Add it in CasaZapp TV as an M3U playlist:

```
https://raw.githubusercontent.com/QuadNL/CasaZapp-TV-release/main/demo/playlist.m3u
```

It also has four films and a short series:

- *Big Buck Bunny*, *Elephants Dream*, *Tears of Steel* and the *Sintel* trailer: open movies by the
  Blender Foundation, © Blender Foundation, CC BY 3.0 (https://www.blender.org, https://archive.org).
- *Short Clips*: three test clips from https://test-videos.co.uk.

The posters are made for the demo (`poster.html`). Films and series need CasaZapp TV with a server;
the app on its own plays the channels.

The guide comes along by itself. It covers three days; `node demo/make-demo.mjs` moves it to the
current days again. `logo-tile.html` draws the logos.
