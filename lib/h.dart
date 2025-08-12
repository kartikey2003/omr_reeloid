import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:just_audio/just_audio.dart';

class MultiAudioPlayer extends StatefulWidget {
  const MultiAudioPlayer({Key? key}) : super(key: key);

  @override
  State<MultiAudioPlayer> createState() => _MultiAudioPlayerState();
}

class _MultiAudioPlayerState extends State<MultiAudioPlayer> {
  late BetterPlayerController _betterPlayerController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final String videoUrl =
      "https://1500033163.vod-qcloud.com/1440fb6evodsgp1500033163/93417e6f1397757909725153541/1XVLBp1aLr0A.mp4";

  final Map<String, String> audioTracks = {
    "Hindi":
    "https://1500033163.vod-qcloud.com/1440fb6evodsgp1500033163/c87be6db1397757909699155424/DihMYRc49MMA.mp3",
    "English":
    "https://1500033163.vod-qcloud.com/1440fb6evodsgp1500033163/c87a529f1397757909699152818/AkfAA6ZH3ykA.mp3",
    "Bengali":
    "https://1500033163.vod-qcloud.com/1440fb6evodsgp1500033163/95851fb81397757909725244684/PATrhzNKpsoA.mp3",
  };

  final Map<String, double> playbackSpeeds = {
    "0.5x": 0.5,
    "0.75x": 0.75,
    "1x": 1.0,
    "1.25x": 1.25,
    "1.5x": 1.5,
    "2x": 2.0,
  };

  String selectedAudioTrack = "English";
  String selectedPlaybackSpeed = "1x";

  @override
  void initState() {
    super.initState();

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      videoUrl,
    );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        looping: false,
        aspectRatio: 9 / 16,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          enableAudioTracks: false,
          showControls: false,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );

    // Sync video pause/resume with audio
    _betterPlayerController.videoPlayerController?.addListener(() async {
      if (_betterPlayerController.videoPlayerController!.value.isPlaying) {
        if (!_audioPlayer.playing) {
          _audioPlayer.play();
        }
      } else {
        if (_audioPlayer.playing) {
          _audioPlayer.pause();
        }
      }
    });

    // Default start with English audio
    _playAudio(audioTracks[selectedAudioTrack]!);
  }

  Future<void> _playAudio(String url) async {
    await _audioPlayer.setUrl(url);
    _audioPlayer.play();
  }

  Future<void> _switchAudio(String language, String url) async {
    Duration? pos = await _betterPlayerController.videoPlayerController?.position;
    if (pos != null) {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.seek(pos);
      _audioPlayer.play();
      setState(() {
        selectedAudioTrack = language;
      });
    }
  }

  void _changePlaybackSpeed(double speed) {
    _betterPlayerController.setSpeed(speed);
    _audioPlayer.setSpeed(speed);
    setState(() {
      selectedPlaybackSpeed = playbackSpeeds.entries
          .firstWhere((entry) => entry.value == speed)
          .key;
    });
  }

  void _showVideoSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          color: Colors.black26,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Video Settings",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Playback Speed Section
              const Text(
                "Playback Speed",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                children: playbackSpeeds.entries.map((entry) {
                  bool isSelected = selectedPlaybackSpeed == entry.key;
                  return GestureDetector(
                    onTap: () {
                      _changePlaybackSpeed(entry.value);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Audio Track Section
              const Text(
                "Audio Language",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              ...audioTracks.entries.map((entry) {
                bool isSelected = selectedAudioTrack == entry.key;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  leading: Radio<String>(
                    value: entry.key,
                    groupValue: selectedAudioTrack,
                    onChanged: (value) {
                      if (value != null) {
                        Navigator.pop(context);
                        _switchAudio(value, entry.value);
                      }
                    },
                  ),
                  title: Text(
                    entry.key,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _switchAudio(entry.key, entry.value);
                  },
                );
              }).toList(),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BetterPlayer(controller: _betterPlayerController),

          // Floating settings button
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: _showVideoSettings,
                  child: Column(
                    children: const [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.video_settings, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}