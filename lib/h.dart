import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final Player player;
  late final VideoController controller;
  List<AudioTrack> audioTracks = [];
  List<SubtitleTrack> subtitleTracks = [];
  int currentAudioIndex = 0;
  int? currentSubtitleIndex; // Null = subtitles off

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);

    // Load video
    player.open(
      Media(
        "https://1326678901.vod-qcloud.com/0d16610cvodhk1326678901/f44975dd5145403695130258515/9ApnbHtoI2YA.mp4",
      ),
    );

    // Listen for audio and subtitle tracks
    player.stream.tracks.listen((tracks) {
      final filteredAudio = tracks.audio
          .where((track) =>
      track.id.trim().isNotEmpty &&
          track.codec != null &&
          track.codec!.toLowerCase() != 'unknown')
          .toList();

      final filteredSubtitles = tracks.subtitle
          .where((track) =>
      track.id.trim().isNotEmpty &&
          track.codec != null &&
          track.codec!.toLowerCase() != 'unknown')
          .toList();

      setState(() {
        audioTracks = filteredAudio;
        subtitleTracks = filteredSubtitles;
        if (currentSubtitleIndex == null && subtitleTracks.isNotEmpty) {
          player.setSubtitleTrack(SubtitleTrack.no());
        }
      });
    });
  }

  void changeAudioTrack(int index) {
    if (index >= 0 && index < audioTracks.length) {
      player.setAudioTrack(audioTracks[index]); // Fixed: Pass AudioTrack object
      setState(() {
        currentAudioIndex = index;
      });
      debugPrint("Switched to audio track: ${audioTracks[index].title ?? audioTracks[index].language ?? audioTracks[index].id}");
    }
  }

  void changeSubtitleTrack(int? index) {
    if (index == null) {
      player.setSubtitleTrack(SubtitleTrack.no());
      setState(() => currentSubtitleIndex = null);
      debugPrint("Subtitles turned off");
    } else if (index >= 0 && index < subtitleTracks.length) {
      player.setSubtitleTrack(subtitleTracks[index]);
      setState(() => currentSubtitleIndex = index);
      debugPrint("Switched to subtitle track: ${subtitleTracks[index].title ?? subtitleTracks[index].language ?? subtitleTracks[index].id}");
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video 9:16 mobile aspect ratio
            Center(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Video(
                  controller: controller,
                  subtitleViewConfiguration: const SubtitleViewConfiguration(
                    visible: true,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),

            // Settings & extra buttons
            Positioned(
              bottom: 20,
              right: 20,
              child: Column(
                children: [
                  // Bookmark button (dummy)
                  IconButton(
                    icon: const Icon(Icons.bookmark, color: Colors.white),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 10),
                  // Comment button (dummy)
                  IconButton(
                    icon: const Icon(Icons.comment, color: Colors.white),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 10),
                  // Settings button (borderless)
                  FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.black87,
                        builder: (_) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Audio Tracks',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (audioTracks.isNotEmpty)
                                ...List.generate(audioTracks.length, (index) {
                                  final title = audioTracks[index].title?.isNotEmpty == true
                                      ? audioTracks[index].title!
                                      : (audioTracks[index].language?.isNotEmpty == true
                                      ? audioTracks[index].language!
                                      : "Track ${index + 1}");
                                  return ListTile(
                                    title: Text(title, style: const TextStyle(color: Colors.white)),
                                    trailing: currentAudioIndex == index
                                        ? const Icon(Icons.check, color: Colors.green)
                                        : null,
                                    onTap: () {
                                      changeAudioTrack(index);
                                      Navigator.pop(context);
                                    },
                                  );
                                })
                              else
                                const ListTile(
                                  title: Text('No audio tracks available', style: TextStyle(color: Colors.white70)),
                                ),
                              const Divider(color: Colors.white54),
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Subtitles',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Subtitles off
                              ListTile(
                                title: const Text('Off', style: TextStyle(color: Colors.white)),
                                trailing: currentSubtitleIndex == null
                                    ? const Icon(Icons.check, color: Colors.green)
                                    : null,
                                onTap: () {
                                  changeSubtitleTrack(null);
                                  Navigator.pop(context);
                                },
                              ),
                              if (subtitleTracks.isNotEmpty)
                                ...List.generate(subtitleTracks.length, (index) {
                                  final title = subtitleTracks[index].title?.isNotEmpty == true
                                      ? subtitleTracks[index].title!
                                      : (subtitleTracks[index].language?.isNotEmpty == true
                                      ? subtitleTracks[index].language!
                                      : "Subtitle ${index + 1}");
                                  return ListTile(
                                    title: Text(title, style: const TextStyle(color: Colors.white)),
                                    trailing: currentSubtitleIndex == index
                                        ? const Icon(Icons.check, color: Colors.green)
                                        : null,
                                    onTap: () {
                                      changeSubtitleTrack(index);
                                      Navigator.pop(context);
                                    },
                                  );
                                })
                              else
                                const ListTile(
                                  title: Text('No subtitles available', style: TextStyle(color: Colors.white70)),
                                ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}