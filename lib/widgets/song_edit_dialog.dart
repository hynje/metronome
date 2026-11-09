import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/song.dart';
import '../theme.dart';

/// 곡 제목·BPM·박자를 편집하는 다이얼로그. 저장하면 수정된 [Song]을,
/// 취소하면 null을 돌려준다.
Future<Song?> showSongEditDialog(BuildContext context, Song song) {
  return showDialog<Song>(
    context: context,
    builder: (_) => _SongEditDialog(song: song),
  );
}

class _SongEditDialog extends StatefulWidget {
  const _SongEditDialog({required this.song});

  final Song song;

  @override
  State<_SongEditDialog> createState() => _SongEditDialogState();
}

class _SongEditDialogState extends State<_SongEditDialog> {
  late final _title = TextEditingController(text: widget.song.title);
  late final _bpm = TextEditingController(text: '${widget.song.bpm}');
  late final _beat = TextEditingController(text: '${widget.song.beat}');

  @override
  void dispose() {
    _title.dispose();
    _bpm.dispose();
    _beat.dispose();
    super.dispose();
  }

  void _save() {
    // 비어 있거나 숫자가 아니면 원래 값을 유지하고, 범위 밖이면 범위 안으로 맞춘다.
    final bpm = int.tryParse(_bpm.text) ?? widget.song.bpm;
    final beat = int.tryParse(_beat.text) ?? widget.song.beat;
    Navigator.pop(
      context,
      Song(title: _title.text, bpm: clampBpm(bpm), beat: clampBeat(beat)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_title, 'title'),
            _field(_bpm, 'bpm : $kMinBpm - $kMaxBpm', numeric: true),
            _field(_beat, 'beat : $kMinBeat - $kMaxBeat', numeric: true),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.text,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.primary,
            shadowColor: Colors.black,
            elevation: 2.0,
          ),
          child: const Text('save'),
        ),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label,
      {bool numeric = false}) {
    return TextField(
      controller: controller,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      inputFormatters:
          numeric ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.text),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        labelStyle: const TextStyle(color: AppColors.text),
        labelText: label,
      ),
    );
  }
}
