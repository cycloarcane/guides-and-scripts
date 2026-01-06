# Downloading YouTube Videos with Audio Using yt-dlp (Arch Linux)

When downloading YouTube videos at 1080p or higher, it is normal for video and audio to be provided as **separate streams**. This is how YouTube’s DASH streaming works. To get a final video file **with sound**, yt-dlp must download both streams and merge them using ffmpeg.

This guide shows the correct commands to do that.

---

## Prerequisites

Ensure both tools are installed:

```bash
sudo pacman -S yt-dlp ffmpeg
```

`ffmpeg` is required to merge video and audio. Without it, yt-dlp will download video-only files.

---

## Inspect Available Formats (Optional)

To see what formats YouTube provides:

```bash
yt-dlp -F https://www.youtube.com/watch?v=VIDEO_ID
```

Formats marked **video only** and **audio only** must be merged.

---

## Recommended Command (Automatic, Best Choice)

This command automatically downloads the best video and best audio and merges them into a single MP4 file:

```bash
yt-dlp -f "bv*+ba/b" --merge-output-format mp4 https://www.youtube.com/watch?v=VIDEO_ID
```

What this does:

* `bv*` selects the best available video stream
* `ba` selects the best available audio stream
* `/b` falls back to a single combined stream if necessary
* `--merge-output-format mp4` ensures a standard MP4 output

This is the preferred command for most use cases.

---

## Explicit Format Selection (Maximum Control)

### 1080p H.264 Video + AAC Audio (Maximum Compatibility)

```bash
yt-dlp -f "137+140" --merge-output-format mp4 https://www.youtube.com/watch?v=VIDEO_ID
```

* `137` = 1080p H.264 video
* `140` = AAC audio (m4a)

Recommended if the file needs to play on older devices or strict players.

---

### 1080p VP9 Video + Opus Audio (Better Compression)

```bash
yt-dlp -f "248+251" https://www.youtube.com/watch?v=VIDEO_ID
```

Recommended if you want better compression and quality and do not need legacy device support.

---

## Common Pitfall

If your downloaded video has no audio:

* `ffmpeg` is not installed, or
* you selected a **video-only** format without adding an audio stream

Fix by installing ffmpeg and using one of the merge commands above.

---

## Summary

* 1080p+ YouTube videos are video-only by design
* Audio must be downloaded separately
* yt-dlp merges streams automatically when ffmpeg is available
* Use `bv*+ba/b` unless you have a specific reason not to

---
