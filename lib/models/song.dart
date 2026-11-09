/// 메트로놈이 다룰 수 있는 템포·박자 범위.
const int kMinBpm = 40;
const int kMaxBpm = 265;
const int kMinBeat = 2;
const int kMaxBeat = 7;

const int kDefaultBpm = 120;
const int kDefaultBeat = 4;
const String kDefaultSongTitle = 'input song name';

int clampBpm(int bpm) => bpm.clamp(kMinBpm, kMaxBpm);
int clampBeat(int beat) => beat.clamp(kMinBeat, kMaxBeat);

/// 세트리스트의 곡 하나.
class Song {
  const Song({
    this.title = kDefaultSongTitle,
    this.bpm = kDefaultBpm,
    this.beat = kDefaultBeat,
  });

  final String title;
  final int bpm;
  final int beat;

  Song copyWith({String? title, int? bpm, int? beat}) => Song(
        title: title ?? this.title,
        bpm: bpm ?? this.bpm,
        beat: beat ?? this.beat,
      );

  @override
  bool operator ==(Object other) =>
      other is Song &&
      other.title == title &&
      other.bpm == bpm &&
      other.beat == beat;

  @override
  int get hashCode => Object.hash(title, bpm, beat);
}
