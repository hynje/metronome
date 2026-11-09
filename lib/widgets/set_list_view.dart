import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../state/metronome_controller.dart';
import '../state/setlist_controller.dart';
import '../theme.dart';
import 'song_edit_dialog.dart';

/// 세트리스트 목록. 탭하면 곡을 불러오고, 길게 누르면 편집한다.
class SetListView extends StatelessWidget {
  const SetListView({super.key});

  @override
  Widget build(BuildContext context) {
    final setList = context.watch<SetListController>();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.brown.shade600),
        borderRadius: BorderRadius.circular(8),
      ),
      child: !setList.isLoaded
          ? const SizedBox.shrink()
          : ListView.builder(
              itemCount: setList.songs.length,
              itemBuilder: (context, index) => _SongTile(
                index: index,
                song: setList.songs[index],
                isSelected: setList.selectedIndex == index,
              ),
            ),
    );
  }
}

class _SongTile extends StatelessWidget {
  const _SongTile({
    required this.index,
    required this.song,
    required this.isSelected,
  });

  final int index;
  final Song song;
  final bool isSelected;

  void _load(BuildContext context) {
    final selected = context.read<SetListController>().select(index);
    context.read<MetronomeController>().applySong(selected);
  }

  Future<void> _edit(BuildContext context) async {
    _load(context);
    final setList = context.read<SetListController>();
    final metronome = context.read<MetronomeController>();
    final edited = await showSongEditDialog(context, song);
    if (edited == null) return;
    metronome.applySong(edited);
    await setList.updateSong(index, edited);
  }

  void _saveCurrentTempo(BuildContext context) {
    final metronome = context.read<MetronomeController>();
    context.read<SetListController>().updateSong(
          index,
          song.copyWith(bpm: metronome.bpm, beat: metronome.beat),
        );
  }

  @override
  Widget build(BuildContext context) {
    // 선택된 곡의 템포를 바꿨으면 저장 버튼을 보여준다.
    final isDirty = context.select((MetronomeController c) =>
        isSelected && (c.bpm != song.bpm || c.beat != song.beat));
    final color = isSelected ? AppColors.primary : AppColors.text;

    return ListTile(
      textColor: color,
      iconColor: color,
      leading: Text('${index + 1}', style: const TextStyle(fontSize: 18)),
      title: Text(song.title),
      subtitle: Row(
        children: [
          const Icon(Icons.music_note, size: 15),
          Text(' : ${song.bpm} , Beat : ${song.beat}'),
        ],
      ),
      trailing: isDirty
          ? ElevatedButton(
              onPressed: () => _saveCurrentTempo(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.primary,
                shadowColor: Colors.black,
                elevation: 1.0,
              ),
              child: const Text('save'),
            )
          : null,
      onTap: () => _load(context),
      onLongPress: () => _edit(context),
    );
  }
}
