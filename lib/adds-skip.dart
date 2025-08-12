import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'homepage.dart';

class VideoAdsSequence extends StatefulWidget {
  const VideoAdsSequence({super.key});

  @override
  State<VideoAdsSequence> createState() => _VideoAdsSequenceState();
}

class _VideoAdsSequenceState extends State<VideoAdsSequence> {
  final List<String> _baseAdds = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://1326678901.vod-qcloud.com/e4004eb4vodtranshk1326678901/947072a23560136622773692360/v.f101302.mp4',
    'https://1326678901.vod-qcloud.com/e4004eb4vodtranshk1326678901/94708baa3560136622773692926/v.f101302.mp4',
    'https://1326678901.vod-qcloud.com/e4004eb4vodtranshk1326678901/9470f2a73560136622773693094/v.f101302.mp4',
  ];

  late VideoPlayerController _controller;
  bool _isInitialized = false;
  int _currentIndex = 0;

  int _seconds = 16;
  bool _canSkip = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeVideo(_baseAdds[_currentIndex]);
  }

  void _initializeVideo(String url) {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
        _controller.addListener(_videoListener);
        if (_currentIndex > 0) _startTimer();
      }).catchError((error) {
        debugPrint("Video failed to initialize: $error");
      });
  }

  void _videoListener() {
    if (_controller.value.position >= _controller.value.duration) {
      _controller.removeListener(_videoListener);
      _moveToNextVideo();
    }
  }

  void _startTimer() {
    _seconds = 16;
    _canSkip = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 1) {
          _seconds--;
        } else {
          timer.cancel();
          _canSkip = true;
        }
      });
    });
  }

  void _moveToNextVideo() {
    _timer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();

    if (_currentIndex < _baseAdds.length - 1) {
      _currentIndex++;
      _isInitialized = false;
      _initializeVideo(_baseAdds[_currentIndex]);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Homepage()),
            (route) => false,
      );
    }
  }

  void _skipCurrentAd() {
    _moveToNextVideo();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:  false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Back button disabled on this screen"),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.topRight,
          fit: StackFit.expand,
          children: [
            _isInitialized
                ? Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
                : const Center(child: CircularProgressIndicator()),
      
            if (_currentIndex > 0)
              Positioned(
                top: 20,
                right: 20,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _canSkip ? _skipCurrentAd : null,
                  child: Text(
                    _canSkip ? "Skip Ads" : "Skip Ads in $_seconds sec",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
