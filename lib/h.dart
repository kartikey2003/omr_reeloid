import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:just_audio/just_audio.dart';

class MultiAudioPlayer extends StatefulWidget {
  const MultiAudioPlayer({super.key});

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
        aspectRatio: 9 / 16, // 9:16 Aspect Ratio

        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableAudioTracks: false, // Disable default audio tracks
          overflowMenuCustomItems: [
            BetterPlayerOverflowMenuItem(
              Icons.audiotrack,
              "Audio",
                  () => _showAudioMenu(),
            ),
          ],
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
    _playAudio(audioTracks["English"]!);
  }

  Future<void> _playAudio(String url) async {
    await _audioPlayer.setUrl(url);
    _audioPlayer.play();
  }

  Future<void> _switchAudio(String url) async {
    Duration? pos =
    await _betterPlayerController.videoPlayerController?.position;
    if (pos != null) {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.seek(pos);
      _audioPlayer.play();
    }
  }

  void _showAudioMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: audioTracks.entries.map((entry) {
            return ListTile(
              title: Text(entry.key),
              onTap: () {
                Navigator.pop(context); // Close menu
                _switchAudio(entry.value);
              },
            );
          }).toList(),
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
      body: BetterPlayer(
        controller: _betterPlayerController,
      ),
    );
  }
}
