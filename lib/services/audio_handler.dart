import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class TTSBackgroundHandler extends BaseAudioHandler {
  final _player = AudioPlayer();

  TTSBackgroundHandler() {
    _player.playerStateStream.listen((state) {
      playbackState.add(playbackState.value.copyWith(
        playing: state.playing,
        controls: [MediaControl.play, MediaControl.pause],
      ));
    });
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }
}
