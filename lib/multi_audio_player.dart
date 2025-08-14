import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:just_audio/just_audio.dart';

class Reelss extends StatefulWidget {
  const Reelss({super.key});

  @override
  State<Reelss> createState() => _ReelssState();
}

class _ReelssState extends State<Reelss> with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  final List<BetterPlayerController> _controllers = [];
  final List<AudioPlayer> _audioPlayers = [];
  List<bool> _showDropup = [];

  final List<String> _baseVideos = [
    'https://1326678901.vod-qcloud.com/e4004eb4vodtranshk1326678901/947072a23560136622773692360/v.f101302.mp4',
    'https://1326678901.vod-qcloud.com/e4004eb4vodtranshk1326678901/94708baa3560136622773692926/v.f101302.mp4',
    'https://1326678901.vod-qcloud.com/e4004eb4vodtranshk1326678901/9470f2a73560136622773693094/v.f101302.mp4',
    'https://1326678901.vod-qcloud.com/e4004eb4vodtranshk1326678901/712388053560136622752772466/v.f101302.mp4',
    'https://1326678901.vod-qcloud.com/e4004eb4vodtranshk1326678901/512d72b73560136622721140395/v.f101302.mp4',
  ];

  List<bool> _isHindiSelected = [];
  int _currentIndex = 0;
  bool _isPlaying = true;
  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeControllers();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;

    switch (state) {
      case AppLifecycleState.paused:
        _pauseAllVideos();
        break;
      case AppLifecycleState.resumed:
        if (_currentIndex < _controllers.length) {
          _controllers[_currentIndex].play();
        }
        break;
      case AppLifecycleState.inactive:
        _pauseAllVideos();
        break;
      default:
        break;
    }
  }

  void _pauseAllVideos() {
    try {
      for (int i = 0; i < _controllers.length; i++) {
        if (!_isDisposed && _controllers[i].isVideoInitialized() == true) {
          _controllers[i].pause();
        }
        if (!_isDisposed && _audioPlayers[i].playerState.playing) {
          _audioPlayers[i].pause();
        }
      }
    } catch (e) {
      print("Error pausing videos: $e");
    }
  }

  void _initializeControllers() async {
    if (_isDisposed) return;

    try {
      _isHindiSelected = List.generate(_baseVideos.length, (index) => false);
      _showDropup = List.generate(_baseVideos.length, (index) => false);

      for (int i = 0; i < _baseVideos.length; i++) {
        if (_isDisposed) break;

        // Initialize video controllers with better error handling
        BetterPlayerDataSource dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          _baseVideos[i],
          cacheConfiguration: BetterPlayerCacheConfiguration(
            useCache: true,
            preCacheSize: 10 * 1024 * 1024, // 10MB
            maxCacheSize: 100 * 1024 * 1024, // 100MB
            maxCacheFileSize: 50 * 1024 * 1024, // 50MB
          ),
        );

        BetterPlayerController controller = BetterPlayerController(
          BetterPlayerConfiguration(
            autoPlay: i == 0,
            looping: true,
            aspectRatio: 9 / 16,
            fit: BoxFit.cover,
            handleLifecycle: false, // We'll handle manually
            autoDetectFullscreenAspectRatio: false,
            autoDetectFullscreenDeviceOrientation: false,
            deviceOrientationsOnFullScreen: [],
            systemOverlaysAfterFullScreen: [],
            errorBuilder: (context, errorMessage) {
              return Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.white, size: 50),
                      SizedBox(height: 10),
                      Text(
                        'Video loading failed',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () => _retryVideo(i),
                        child: Text('Retry', style: TextStyle(color: Colors.orange)),
                      ),
                    ],
                  ),
                ),
              );
            },
            controlsConfiguration: BetterPlayerControlsConfiguration(
              showControls: false,
              enablePlaybackSpeed: false,
              enablePip: false,
              enableSkips: false,
              enableFullscreen: false,
              enableAudioTracks: false,
              enableSubtitles: false,
              enablePlayPause: false,
              enableMute: false,
              // enableProgressIndicator: false,
              showControlsOnInitialize: false,
            ),
          ),
          betterPlayerDataSource: dataSource,
        );

        controller.addEventsListener((event) {
          if (!_isDisposed) {
            _handleVideoEvents(event, i);
          }
        });

        _controllers.add(controller);

        // Initialize audio players
        AudioPlayer audioPlayer = AudioPlayer();
        _audioPlayers.add(audioPlayer);
      }

      if (!_isDisposed && mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print("Error initializing controllers: $e");
      if (!_isDisposed && mounted) {
        setState(() {
          _isInitialized = true; // Show UI even with errors
        });
      }
    }
  }

  void _retryVideo(int index) {
    if (_isDisposed || index >= _controllers.length) return;

    try {
      _controllers[index].retryDataSource();
    } catch (e) {
      print("Error retrying video: $e");
    }
  }

  void _handleVideoEvents(BetterPlayerEvent event, int index) {
    if (_isDisposed || !mounted || index != _currentIndex || index >= _controllers.length) {
      return;
    }

    try {
      if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
        if (_isHindiSelected[index] &&
            _controllers[index].isVideoInitialized() == true &&
            _controllers[index].videoPlayerController != null &&
            !_controllers[index].videoPlayerController!.value.hasError) {

          final position = _controllers[index].videoPlayerController!.value.position;
          if (!_isDisposed &&
              index < _audioPlayers.length &&
              _audioPlayers[index].playerState.playing) {
            final audioPosition = _audioPlayers[index].position;
            final difference = (position - audioPosition).inMilliseconds.abs();
            if (difference > 200) {
              _audioPlayers[index].seek(position).catchError((e) {
                print("Error seeking audio: $e");
              });
            }
          }
        }
      }

      // Handle play/pause state changes
      if (event.betterPlayerEventType == BetterPlayerEventType.play) {
        if (!_isDisposed && mounted) {
          setState(() {
            _isPlaying = true;
          });
          if (_isHindiSelected[index] && index < _audioPlayers.length) {
            _audioPlayers[index].play().catchError((e) {
              print("Error playing audio: $e");
            });
          }
        }
      } else if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
        if (!_isDisposed && mounted) {
          setState(() {
            _isPlaying = false;
          });
          if (_isHindiSelected[index] && index < _audioPlayers.length) {
            _audioPlayers[index].pause().catchError((e) {
              print("Error pausing audio: $e");
            });
          }
        }
      }
    } catch (e) {
      print("Error handling video events: $e");
    }
  }

  Future<void> _switchToHindi(int index) async {
    if (_isDisposed || _isHindiSelected[index] || !mounted || index >= _controllers.length) {
      return;
    }

    try {
      setState(() {
        _isHindiSelected[index] = true;
      });

      // Check if video controller is valid
      if (_controllers[index].videoPlayerController == null ||
          _controllers[index].videoPlayerController!.value.hasError) {
        return;
      }

      final videoPosition = _controllers[index].videoPlayerController!.value.position;

      // Mute video
      await _controllers[index].setVolume(0.0);

      // Load and play Hindi audio
      if (index < _audioPlayers.length) {
        await _audioPlayers[index].setAsset("assets/audio/hindi_audio_$index.mp3");
        await _audioPlayers[index].seek(videoPosition);

        if (_isPlaying && index == _currentIndex && !_isDisposed) {
          await _audioPlayers[index].play();
        }
      }
    } catch (e) {
      print("Error switching to Hindi: $e");
      // Reset state on error
      if (!_isDisposed && mounted) {
        setState(() {
          _isHindiSelected[index] = false;
        });
      }
    }
  }

  Future<void> _switchToEnglish(int index) async {
    if (_isDisposed || !_isHindiSelected[index] || !mounted || index >= _controllers.length) {
      return;
    }

    try {
      setState(() {
        _isHindiSelected[index] = false;
      });

      // Unmute video
      await _controllers[index].setVolume(1.0);

      // Pause Hindi audio
      if (index < _audioPlayers.length) {
        await _audioPlayers[index].pause();
      }
    } catch (e) {
      print("Error switching to English: $e");
    }
  }

  void _togglePlayPause() {
    if (_isDisposed || !mounted || _currentIndex >= _controllers.length) return;

    try {
      if (_controllers[_currentIndex].isVideoInitialized() != true) return;

      if (_isPlaying) {
        _controllers[_currentIndex].pause();
        if (_isHindiSelected[_currentIndex] && _currentIndex < _audioPlayers.length) {
          _audioPlayers[_currentIndex].pause();
        }
      } else {
        _controllers[_currentIndex].play();
        if (_isHindiSelected[_currentIndex] && _currentIndex < _audioPlayers.length) {
          _audioPlayers[_currentIndex].play();
        }
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      print("Error toggling play/pause: $e");
    }
  }

  void _toggleDropup(int index) {
    if (_isDisposed || !mounted) return;

    setState(() {
      for (int i = 0; i < _showDropup.length; i++) {
        _showDropup[i] = (i == index) ? !_showDropup[i] : false;
      }
    });
  }

  void _onPageChanged(int index) {
    if (_isDisposed || !mounted || index >= _controllers.length) return;

    try {
      // Close any open dropups
      setState(() {
        for (int i = 0; i < _showDropup.length; i++) {
          _showDropup[i] = false;
        }
      });

      // Pause previous video and audio
      if (_currentIndex < _controllers.length &&
          _controllers[_currentIndex].isVideoInitialized() == true) {
        _controllers[_currentIndex].pause();
        if (_isHindiSelected[_currentIndex] && _currentIndex < _audioPlayers.length) {
          _audioPlayers[_currentIndex].pause();
        }
      }

      _currentIndex = index;

      // Play new video with bounds check
      if (index < _controllers.length &&
          _controllers[index].isVideoInitialized() == true) {
        _controllers[index].play();
        if (_isHindiSelected[index] && index < _audioPlayers.length) {
          _audioPlayers[index].play();
        }
      }

      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      print("Error changing page: $e");
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);

    // Dispose controllers in background to prevent blocking
    Future.microtask(() async {
      try {
        // Dispose video controllers
        for (var controller in _controllers) {
          try {
            if (controller.isVideoInitialized() == true) {
              await controller.pause();
            }
            controller.dispose();
          } catch (e) {
            print("Error disposing video controller: $e");
          }
        }

        // Dispose audio players
        for (var audioPlayer in _audioPlayers) {
          try {
            await audioPlayer.stop();
            await audioPlayer.dispose();
          } catch (e) {
            print("Error disposing audio player: $e");
          }
        }

        // Dispose page controller
        try {
          _pageController.dispose();
        } catch (e) {
          print("Error disposing page controller: $e");
        }
      } catch (e) {
        print("Error in dispose: $e");
      }
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return Container(color: Colors.black);
    }

    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.orange),
              SizedBox(height: 20),
              Text(
                'Loading videos...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: _baseVideos.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              if (_isDisposed || index >= _controllers.length) {
                return Container(
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }

              return GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    children: [
                      // Video Player
                      Center(
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: _controllers[index].isVideoInitialized() == true
                              ? BetterPlayer(controller: _controllers[index])
                              : Container(
                            color: Colors.black,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Play/Pause overlay
                      if (!_isPlaying && index == _currentIndex)
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        ),

                      // Audio Language Dropup - Bottom Right
                      Positioned(
                        bottom: 150,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Dropup Options
                            if (index < _showDropup.length && _showDropup[index]) ...[
                              // Hindi Option
                              GestureDetector(
                                onTap: () {
                                  _switchToHindi(index);
                                  _toggleDropup(index);
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: (index < _isHindiSelected.length && _isHindiSelected[index])
                                        ? Colors.orange : Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.orange, width: 1),
                                  ),
                                  child: Text(
                                    'हिंदी',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // English Option
                              GestureDetector(
                                onTap: () {
                                  _switchToEnglish(index);
                                  _toggleDropup(index);
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: (index < _isHindiSelected.length && !_isHindiSelected[index])
                                        ? Colors.orange : Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.orange, width: 1),
                                  ),
                                  child: Text(
                                    'English',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            // Main Language Button
                            GestureDetector(
                              onTap: () => _toggleDropup(index),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: Colors.orange, width: 2),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.language,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      (index < _isHindiSelected.length && _isHindiSelected[index])
                                          ? 'हिंदी' : 'English',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      (index < _showDropup.length && _showDropup[index])
                                          ? Icons.keyboard_arrow_down
                                          : Icons.keyboard_arrow_up,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Video Counter
                      Positioned(
                        top: 50,
                        right: 20,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${index + 1}/${_baseVideos.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Instructions
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Text(
              'Swipe up/down to navigate • Tap to play/pause • Tap language for audio',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}