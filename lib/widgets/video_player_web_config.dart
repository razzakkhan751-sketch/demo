// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

void registerWebVideoPlayer(
  String elementId,
  String videoUrl,
  String? thumbnailUrl,
) {
  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(elementId, (int viewId) {
    final container = html.DivElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = 'black';

    final isYouTube =
        videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be');

    // Video.js implementation via injected HTML
    container.innerHtml =
        """
      <link href="https://vjs.zencdn.net/8.10.0/video-js.css" rel="stylesheet" />
      <script src="https://vjs.zencdn.net/8.10.0/video.min.js"></script>
      ${isYouTube ? '<script src="https://cdnjs.cloudflare.com/ajax/libs/videojs-youtube/3.0.1/Youtube.min.js"></script>' : ''}
      
      <video
        id="vid-$elementId"
        class="video-js vjs-default-skin vjs-big-play-centered"
        controls
        preload="auto"
        width="100%"
        height="100%"
        poster="${thumbnailUrl ?? ''}"
        data-setup='{
          "techOrder": [${isYouTube ? '"youtube"' : '"html5"'}],
          "sources": [{ "type": "${isYouTube ? 'video/youtube' : 'video/mp4'}", "src": "$videoUrl" }]
        }'>
        <p class="vjs-no-js">
          To view this video please enable JavaScript, and consider upgrading to a
          web browser that <a href="https://videojs.com/html5-video-support/" target="_blank">supports HTML5 video</a>
        </p>
      </video>
    """;

    return container;
  });
}
