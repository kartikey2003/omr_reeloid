import 'package:equatable/equatable.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}

class InitVideo extends VideoEvent {}

class ChangeAudioTrack extends VideoEvent {
  final String audioUrl;

  const ChangeAudioTrack(this.audioUrl);

  @override
  List<Object?> get props => [audioUrl];
}

class SyncPlayPause extends VideoEvent {
  final bool isPlaying;

  const SyncPlayPause(this.isPlaying);

  @override
  List<Object?> get props => [isPlaying];
}

class DisposeVideo extends VideoEvent {}
