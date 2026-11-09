import 'package:audioplayers/audioplayers.dart';

/// 박마다 클릭 소리를 내는 역할.
abstract class ClickPlayer {
  Future<void> init();
  void click();
  Future<void> dispose();
}

/// 미리 로드해 둔 플레이어 풀로 클릭 소리를 재생한다.
///
/// 박마다 AudioPlayer를 새로 만들지 않아서 지연과 리소스 누수가 없다.
class AudioPoolClickPlayer implements ClickPlayer {
  AudioPoolClickPlayer({this.assetPath = 'single-beep_C_major.wav'});

  final String assetPath;
  AudioPool? _pool;

  @override
  Future<void> init() async {
    _pool ??= await AudioPool.createFromAsset(
      path: assetPath,
      minPlayers: 2,
      maxPlayers: 4,
    );
  }

  @override
  void click() {
    _pool?.start();
  }

  @override
  Future<void> dispose() async {
    await _pool?.dispose();
    _pool = null;
  }
}
