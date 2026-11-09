import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metronome/main.dart';
import 'package:metronome/models/song.dart';
import 'package:metronome/services/click_player.dart';
import 'package:metronome/services/song_repository.dart';
import 'package:metronome/state/metronome_controller.dart';
import 'package:metronome/state/setlist_controller.dart';

class FakeClickPlayer implements ClickPlayer {
  int clicks = 0;

  @override
  Future<void> init() async {}

  @override
  void click() => clicks++;

  @override
  Future<void> dispose() async {}
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('SongRepository', () {
    test('저장된 값이 없으면 기본 곡 10개를 돌려준다', () async {
      final songs = await SongRepository().load();
      expect(songs, hasLength(SongRepository.songCount));
      expect(songs.every((s) => s == const Song()), isTrue);
    });

    test('예전 형식("120.0")으로 저장된 BPM도 읽는다', () async {
      SharedPreferences.setMockInitialValues({
        'songList': ['A', 'B'],
        'bpmList': ['98.0', '300'],
        'beatList': ['3', '1'],
      });
      final songs = await SongRepository().load();
      expect(songs[0], const Song(title: 'A', bpm: 98, beat: 3));
      expect(songs[1], const Song(title: 'B', bpm: kMaxBpm, beat: kMinBeat));
      expect(songs[2], const Song());
    });

    test('저장 후 다시 불러오면 같은 값이다', () async {
      final repo = SongRepository();
      final songs = await repo.load();
      songs[4] = const Song(title: 'Intro', bpm: 140, beat: 6);
      await repo.save(songs);
      expect((await repo.load())[4], songs[4]);
    });
  });

  group('MetronomeController', () {
    test('BPM과 박자는 허용 범위 안으로 맞춰진다', () {
      final c = MetronomeController(clickPlayer: FakeClickPlayer());
      c.setBpm(10);
      expect(c.bpm, kMinBpm);
      c.setBpm(999);
      expect(c.bpm, kMaxBpm);
      c.setBeat(1);
      expect(c.beat, kMinBeat);
      c.setBeat(9);
      expect(c.beat, kMaxBeat);
      c.dispose();
    });

    test('applySong은 곡의 템포와 박자를 적용한다', () {
      final c = MetronomeController(clickPlayer: FakeClickPlayer());
      c.applySong(const Song(bpm: 90, beat: 3));
      expect((c.bpm, c.beat), (90, 3));
      c.dispose();
    });

    test('재생하면 즉시 첫 박이 울리고, 정지하면 박 표시가 초기화된다', () {
      final player = FakeClickPlayer();
      final c = MetronomeController(clickPlayer: player);
      c.start();
      expect(c.isPlaying, isTrue);
      expect(player.clicks, 1);
      expect(c.currentBeat, 1);
      c.stop();
      expect(c.isPlaying, isFalse);
      expect(c.currentBeat, 0);
      c.dispose();
    });
  });

  test('SetListController.updateSong은 값을 저장한다', () async {
    final repo = SongRepository();
    final c = SetListController(repository: repo);
    await c.load();
    await c.updateSong(0, const Song(title: 'X', bpm: 500, beat: 5));
    expect(c.songs[0], const Song(title: 'X', bpm: kMaxBpm, beat: 5));
    expect((await repo.load())[0], c.songs[0]);
  });

  testWidgets('앱이 뜨고, 곡을 탭하면 그 곡의 템포가 적용된다', (tester) async {
    SharedPreferences.setMockInitialValues({
      'songList': ['Ballad'],
      'bpmList': ['72'],
      'beatList': ['3'],
    });
    await tester.pumpWidget(MyApp(clickPlayer: FakeClickPlayer()));
    await tester.pumpAndSettle();

    expect(find.text('$kDefaultBpm'), findsOneWidget);
    await tester.tap(find.text('Ballad'));
    await tester.pump();
    expect(find.text('72'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('73'), findsOneWidget);
    expect(find.text('save'), findsOneWidget);
  });
}
