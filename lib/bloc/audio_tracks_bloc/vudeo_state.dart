import 'package:equatable/equatable.dart';

class VideoState extends Equatable {
  final String selectedAudioUrl;
  final bool isPlaying;

  const VideoState({
    required this.selectedAudioUrl,
    required this.isPlaying,
  });

  VideoState copyWith({
    String? selectedAudioUrl,
    bool? isPlaying,
  }) {
    return VideoState(
      selectedAudioUrl: selectedAudioUrl ?? this.selectedAudioUrl,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object?> get props => [selectedAudioUrl, isPlaying];
}
