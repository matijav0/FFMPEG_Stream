# FFMPEG_Stream

Converts a live AAC radio stream into a local HLS stream (`.m3u8`) usable by Unreal Engine's ElectraPlayer.

## Requirements

- [FFmpeg](https://ffmpeg.org/download.html) — `brew install ffmpeg`
- Python 3 (for local HTTP server, included with macOS)

## Usage

```bash
chmod +x stream.sh
./stream.sh
```

The script will:
1. Pull the live AAC stream from StreamTheWorld
2. Segment it into HLS chunks via FFmpeg
3. Serve the playlist locally at `http://localhost:8080/stream.m3u8`

## Unreal Engine setup

In your `StreamMediaSource` asset, set the Stream URL to:

```
http://localhost:8080/stream.m3u8
```

Make sure `stream.sh` is running before you hit Play in UE.

## Stream source

Radio Rijeka — `https://29083.live.streamtheworld.com/RIJEKAAAC.aac`
