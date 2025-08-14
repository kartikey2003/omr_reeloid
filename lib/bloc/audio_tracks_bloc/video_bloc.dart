// import 'package:better_player/better_player.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
// import 'package:new_u/bloc/audio_tracks_bloc/vudeo_state.dart';
// import 'video_event.dart';
//
// class VideoBloc extends Bloc<VideoEvent, VideoState> {
//   final BetterPlayerController betterPlayerController;
//   final AudioPlayer audioPlayer;
//   final String videoUrl;
//   final Map<String, String> audioTracks;
//
//   VideoBloc({
//     required this.betterPlayerController,
//     required this.audioPlayer,
//     required this.videoUrl,
//     required this.audioTracks,
//   }) : super(
//          VideoState(
//            selectedAudioUrl: audioTracks["English"]!,
//            isPlaying: false,
//          ),
//        ) {
//     on<InitVideo>(_onInitVideo);
//     on<ChangeAudioTrack>(_onChangeAudioTrack);
//     on<SyncPlayPause>(_onSyncPlayPause);
//     on<DisposeVideo>(_onDisposeVideo);
//   }
//
//   Future<void> _onInitVideo(InitVideo event, Emitter<VideoState> emit) async {
//     await audioPlayer.setUrl(state.selectedAudioUrl);
//     audioPlayer.play();
//
//     betterPlayerController.videoPlayerController?.addListener(() {
//       final isPlaying =
//           betterPlayerController.videoPlayerController!.value.isPlaying;
//       add(SyncPlayPause(isPlaying));
//     });
//   }
//
//   Future<void> _onChangeAudioTrack(
//     ChangeAudioTrack event,
//     Emitter<VideoState> emit,
//   ) async {
//     final pos = await betterPlayerController.videoPlayerController?.position;
//     await audioPlayer.setUrl(event.audioUrl);
//     if (pos != null) {
//       await audioPlayer.seek(pos);
//     }
//     audioPlayer.play();
//     emit(state.copyWith(selectedAudioUrl: event.audioUrl));
//   }
//
//   Future<void> _onSyncPlayPause(
//     SyncPlayPause event,
//     Emitter<VideoState> emit,
//   ) async {
//     if (event.isPlaying) {
//       audioPlayer.play();
//     } else {
//       audioPlayer.pause();
//     }
//     emit(state.copyWith(isPlaying: event.isPlaying));
//   }
//
//   Future<void> _onDisposeVideo(
//     DisposeVideo event,
//     Emitter<VideoState> emit,
//   ) async {
//     betterPlayerController.dispose();
//     audioPlayer.dispose();
//   }
// }
