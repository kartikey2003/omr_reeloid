import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'h.dart';
import 'homepage.dart';
import 'new_slider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  /// Initialize the video controller
  void _initializeVideo() {
    _controller =
        VideoPlayerController.networkUrl(
            Uri.parse(
              // "https://download.blender.org/durian/trailer/sintel_trailer-1080p.mp4",
              "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
            ),
          )
          ..initialize().then((_) {
            setState(() {}); // Refresh UI after initialization
            _controller.play(); // Auto-play video
          })
          ..setVolume(1.0)
          ..setLooping(false);

    _controller.addListener(_videoListener);
  }

  /// Listen to video playback status
  void _videoListener() {
    if (_controller.value.position >= _controller.value.duration &&
        !_controller.value.isPlaying) {
      _navigateToHome();
    }
  }

  /// Navigate to home screen
  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Homepage(),
      ),
          (Route<dynamic> route) => false, // Predicate: remove all previous routes
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  /// Build the responsive video widget
  Widget _buildVideoPlayer() {
    if (_controller.value.isInitialized) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final aspectRatio = _controller.value.aspectRatio;

      return Center(
        child: SizedBox(
          width: screenWidth,
          height: screenWidth / aspectRatio > screenHeight
              ? screenHeight
              : screenWidth / aspectRatio,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(backgroundColor: Colors.black, body: _buildVideoPlayer()),
    );
  }
}
