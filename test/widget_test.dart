import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metronome/main.dart';
import 'package:metronome/models/song.dart';
import 'package:metronome/services/click_player.dart';
import 'package:metronome/services/song_repository.dart';
import 'package:metronome/state/metronome_controller.dart';
import 'package:metronome/state/setlist_controller.dart';

class FakeClickPlayer implements ClickPlayer {
  FakeClickPlayer({this.onInit});

  /// 소리 준비 동작을 바꾸고 싶을 때 사용 (지연, 실패 등).
  final Future<void> Function()? onInit;
  int clicks = 0;
  int initCalls = 0;

  @override
  Future<void> init() async {
    initCalls++;
    await onInit?.call();
  }

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

    test('재생하면 즉시 첫 박이 울리고, 정지하면 박 표시가 초기화된다', () async {
      final player = FakeClickPlayer();
      final c = MetronomeController(clickPlayer: player);
      await c.start();
      expect(c.isPlaying, isTrue);
      expect(player.clicks, 1);
      expect(c.currentBeat, 1);
      c.stop();
      expect(c.isPlaying, isFalse);
      expect(c.currentBeat, 0);
      c.dispose();
    });
  });

  group('MetronomeController 소리 준비', () {
    test('준비가 끝나기 전에 재생을 누르면 준비된 뒤에 시작한다', () async {
      final ready = Completer<void>();
      final player = FakeClickPlayer(onInit: () => ready.future);
      final c = MetronomeController(clickPlayer: player);

      final starting = c.start();
      expect(c.isPlaying, isFalse);
      expect(player.clicks, 0);

      ready.complete();
      await starting;
      expect(c.isPlaying, isTrue);
      expect(player.clicks, 1);
      c.dispose();
    });

    test('준비를 기다리는 중에 정지하면 재생하지 않는다', () async {
      final ready = Completer<void>();
      final c = MetronomeController(
          clickPlayer: FakeClickPlayer(onInit: () => ready.future));

      final starting = c.start();
      c.togglePlay(); // 기다리는 중에 다시 누르면 취소
      ready.complete();
      await starting;
      expect(c.isPlaying, isFalse);
      c.dispose();
    });

    test('불러오기에 실패해도 박은 돌아가고, 다시 시도해 성공하면 표시가 사라진다', () async {
      final reported = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = reported.add;
      addTearDown(() => FlutterError.onError = originalOnError);

      var fail = true;
      final player = FakeClickPlayer(onInit: () async {
        if (fail) throw Exception('asset missing');
      });
      final c = MetronomeController(clickPlayer: player);

      await c.start();
      expect(c.audioFailed, isTrue);
      expect(c.isPlaying, isTrue);
      expect(reported, hasLength(1));

      fail = false;
      await c.retryAudio();
      expect(c.audioFailed, isFalse);
      expect(player.initCalls, 2);
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
    await tester
        .pumpWidget(const MyApp(createClickPlayer: FakeClickPlayer.new));
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

  group('BPM 패널', () {
    Future<void> pumpApp(WidgetTester tester) async {
      await tester
          .pumpWidget(const MyApp(createClickPlayer: FakeClickPlayer.new));
      await tester.pumpAndSettle();
    }

    testWidgets('+를 길게 누르면 계속 올라가고, 떼면 멈춘다', (tester) async {
      await pumpApp(tester);
      final gesture =
          await tester.startGesture(tester.getCenter(find.byIcon(Icons.add)));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 10));
      await tester.pump(const Duration(seconds: 1));
      await gesture.up();
      await tester.pump();

      final c = tester.element(find.byType(MaterialApp));
      final bpm = c.read<MetronomeController>().bpm;
      // 처음엔 120ms 간격, 8번 뒤부터는 40ms 간격 → 1초 동안 대략 12번
      expect(bpm, inInclusiveRange(130, 136));

      await tester.pump(const Duration(seconds: 1));
      expect(c.read<MetronomeController>().bpm, bpm);
    });

    testWidgets('숫자를 드래그한 거리만큼 BPM이 바뀐다', (tester) async {
      await pumpApp(tester);
      await tester.drag(find.text('120'), const Offset(80, 0));
      await tester.pump();
      final c = tester.element(find.byType(MaterialApp));
      // 8px당 1. 터치 판정에 쓰이는 처음 몇 px는 빠질 수 있다.
      expect(c.read<MetronomeController>().bpm, inInclusiveRange(127, 130));

      await tester.drag(find.text('${c.read<MetronomeController>().bpm}'),
          const Offset(-400, 0));
      await tester.pump();
      expect(c.read<MetronomeController>().bpm, inInclusiveRange(77, 82));
    });
  });
}
