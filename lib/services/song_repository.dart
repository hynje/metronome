import 'package:shared_preferences/shared_preferences.dart';

import '../models/song.dart';

/// 세트리스트를 SharedPreferences에 저장하고 불러온다.
///
/// 기존 버전과 같은 키(`songList`, `bpmList`, `beatList`)를 그대로 써서
/// 이미 저장된 사용자 데이터가 유지된다.
class SongRepository {
  static const int songCount = 10;

  static const _titlesKey = 'songList';
  static const _bpmsKey = 'bpmList';
  static const _beatsKey = 'beatList';

  Future<List<Song>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final titles = prefs.getStringList(_titlesKey) ?? const [];
    final bpms = prefs.getStringList(_bpmsKey) ?? const [];
    final beats = prefs.getStringList(_beatsKey) ?? const [];

    return List.generate(songCount, (i) {
      return Song(
        title: i < titles.length ? titles[i] : kDefaultSongTitle,
        bpm: clampBpm(_parseInt(i < bpms.length ? bpms[i] : null, kDefaultBpm)),
        beat: clampBeat(
            _parseInt(i < beats.length ? beats[i] : null, kDefaultBeat)),
      );
    });
  }

  Future<void> save(List<Song> songs) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setStringList(_titlesKey, [for (final s in songs) s.title]),
      prefs.setStringList(_bpmsKey, [for (final s in songs) '${s.bpm}']),
      prefs.setStringList(_beatsKey, [for (final s in songs) '${s.beat}']),
    ]);
  }

  /// 예전 버전은 BPM을 "120.0"처럼 저장했으므로 소수 형태도 받아들인다.
  static int _parseInt(String? value, int fallback) {
    if (value == null) return fallback;
    return double.tryParse(value)?.round() ?? fallback;
  }
}
