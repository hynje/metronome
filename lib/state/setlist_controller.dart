import 'package:flutter/foundation.dart';

import '../models/song.dart';
import '../services/song_repository.dart';

/// 세트리스트의 곡 목록과 선택 상태를 관리한다.
class SetListController extends ChangeNotifier {
  SetListController({required SongRepository repository})
      : _repository = repository;

  final SongRepository _repository;

  List<Song> _songs = const [];
  int? _selectedIndex;
  bool _isLoaded = false;

  List<Song> get songs => _songs;
  int? get selectedIndex => _selectedIndex;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    _songs = List.unmodifiable(await _repository.load());
    _isLoaded = true;
    notifyListeners();
  }

  /// [index]번 곡을 선택하고 그 곡을 돌려준다.
  Song select(int index) {
    _selectedIndex = index;
    notifyListeners();
    return _songs[index];
  }

  Future<void> updateSong(int index, Song song) async {
    final updated = [..._songs];
    updated[index] = Song(
      title: song.title,
      bpm: clampBpm(song.bpm),
      beat: clampBeat(song.beat),
    );
    _songs = List.unmodifiable(updated);
    notifyListeners();
    await _repository.save(_songs);
  }
}
