#!/bin/bash
set -e

STREAM_URL="https://29083.live.streamtheworld.com/RIJEKAAAC.aac?mp=/stream%22"
OUTPUT_DIR="./hls"
PORT=8080

mkdir -p "$OUTPUT_DIR"

# Write a static HLS master playlist so Electra gets proper codec/type info
cat > "$OUTPUT_DIR/stream.m3u8" << 'EOF'
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio",LANGUAGE="hr",NAME="Radio Rijeka",DEFAULT=YES,AUTOSELECT=YES,URI="media.m3u8"
#EXT-X-STREAM-INF:BANDWIDTH=128000,CODECS="mp4a.40.2",AUDIO="audio"
media.m3u8
EOF

echo "FFmpeg HLS stream starting..."
echo "Local HLS URL: http://localhost:$PORT/stream.m3u8"
echo "Use this URL in Unreal Engine StreamMediaSource."
echo ""
echo "Press Ctrl+C to stop."

# Start HTTP server in background
(cd "$OUTPUT_DIR" && python3 -m http.server $PORT --bind 127.0.0.1 2>/dev/null) &
HTTP_PID=$!

cleanup() {
    echo ""
    echo "Stopping..."
    kill "$HTTP_PID" 2>/dev/null || true
    rm -f "$OUTPUT_DIR"/*.ts "$OUTPUT_DIR"/*.m3u8
}
trap cleanup EXIT INT TERM

# FFmpeg: pull AAC stream, segment into HLS media playlist (not master)
ffmpeg \
    -reconnect 1 \
    -reconnect_streamed 1 \
    -reconnect_delay_max 5 \
    -i "$STREAM_URL" \
    -c:a aac \
    -b:a 128k \
    -f hls \
    -hls_time 2 \
    -hls_list_size 5 \
    -hls_flags delete_segments+append_list \
    -hls_segment_filename "$OUTPUT_DIR/segment_%03d.ts" \
    "$OUTPUT_DIR/media.m3u8"
