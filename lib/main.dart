import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/click_player.dart';
import 'services/song_repository.dart';
import 'state/metronome_controller.dart';
import 'state/setlist_controller.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key, ClickPlayer? clickPlayer, SongRepository? songRepository})
      : clickPlayer = clickPlayer ?? AudioPoolClickPlayer(),
        songRepository = songRepository ?? SongRepository();

  final ClickPlayer clickPlayer;
  final SongRepository songRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MetronomeController(clickPlayer: clickPlayer),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SetListController(repository: songRepository)..load(),
        ),
      ],
      child: MaterialApp(
        theme: buildAppTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
