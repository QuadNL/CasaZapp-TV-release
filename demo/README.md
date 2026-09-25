# Demo playlist

Made-up channels to try CasaZapp TV without a subscription of your own, and for the screenshots on
the site. Every channel plays the same public test video (Big Buck Bunny, from Mux's test streams);
the guide and the logos are made up.

Add it in CasaZapp TV as an M3U playlist:

```
https://raw.githubusercontent.com/QuadNL/CasaZapp-TV-release/main/demo/playlist.m3u
```

The guide comes along by itself. It covers three days; `node demo/make-demo.mjs` moves it to the
current days again. `logo-tile.html` draws the logos.
