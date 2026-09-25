# libghost_srt

First-class **SRT** receive library for [GhostVidStream](https://github.com/iHadAThought/GhostVidStream).

Same product bar as `libghost_ndihx`: native `ghost_srt.h` API, `media_core` plugin id `srt`, BGRX `capture_newest`, embed docs.

See `docs/embed.md`.

## Build

```bash
make
sudo make install
```

Requires FFmpeg shared libs with libsrt.

## Hardening (2026-09-25)

ASan soak+reconnect on AIDA H.264 1080p30: **PASS** (Mac lab). Valgrind not available on macOS host.

Encode matrix: see `docs/srt-rtmp-rtsp-encode-compatibility.md`.

## Related

- GhostVidStream: https://github.com/iHadAThought/GhostVidStream
- Companion: libghost_ndihx / libghost_srt / libghost_rtmp / libghost_rtsp
