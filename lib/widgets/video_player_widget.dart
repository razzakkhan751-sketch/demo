import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    as yt_mobile;
import 'package:flutter/foundation.dart';
import 'video_player_stub_config.dart'
    if (dart.library.html) 'video_player_web_config.dart'
    as web_config;

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  // Common
  bool _isYouTube = false;

  // Direct Video
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // YouTube Mobile
  yt_mobile.YoutubePlayerController? _ytMobileController;

  @override
  void initState() {
    super.initState();
    _isYouTube = _checkIfYouTube(widget.videoUrl);
    _initializePlayer();
  }

  bool _checkIfYouTube(String url) {
    return url.contains("youtube.com") || url.contains("youtu.be");
  }

  void _initializePlayer() {
    if (_isYouTube) {
      if (kIsWeb) {
        // Web Config handles YouTube automatically via Video.js or iframe
        web_config.registerWebVideoPlayer(
          'video-js-player',
          widget.videoUrl,
          null,
        ); // Assuming 'video-js-player' is the fixed ID for web
      } else {
        // Mobile YouTube
        final videoId = yt_mobile.YoutubePlayer.convertUrlToId(widget.videoUrl);
        if (videoId != null) {
          _ytMobileController = yt_mobile.YoutubePlayerController(
            initialVideoId: videoId,
            flags: yt_mobile.YoutubePlayerFlags(
              autoPlay: widget.autoPlay,
              mute: false,
            ),
          );
        }
      }
    } else {
      // Direct mp4/HLS
      if (kIsWeb) {
        web_config.registerWebVideoPlayer(
          'video-js-player',
          widget.videoUrl,
          null,
        ); // Assuming 'video-js-player' is the fixed ID for web
      } else {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
        );
        _videoPlayerController!
            .initialize()
            .then((_) {
              if (mounted) {
                setState(() {
                  _chewieController = ChewieController(
                    videoPlayerController: _videoPlayerController!,
                    autoPlay: widget.autoPlay,
                    looping: false,
                    aspectRatio: _videoPlayerController!.value.aspectRatio,
                  );
                });
              }
            })
            .catchError((e) {
              debugPrint("Error initializing direct video player: $e");
            });
      }
    }
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl ||
        oldWidget.autoPlay != widget.autoPlay) {
      // Dispose old controllers
      _videoPlayerController?.dispose();
      _chewieController?.dispose();
      _ytMobileController?.dispose();
      _videoPlayerController = null;
      _chewieController = null;
      _ytMobileController = null;

      // Re-initialize
      _isYouTube = _checkIfYouTube(widget.videoUrl);
      _initializePlayer();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _ytMobileController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const HtmlElementView(viewType: 'video-js-player');
    }

    if (_isYouTube) {
      if (_ytMobileController == null) {
        return const Center(child: Text("Invalid YouTube URL"));
      }
      return yt_mobile.YoutubePlayer(
        controller: _ytMobileController!,
        showVideoProgressIndicator: true,
      );
    }

    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    }

    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              "Initializing Video...",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
