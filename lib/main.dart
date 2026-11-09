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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.createClickPlayer, this.songRepository});

  /// 테스트에서 가짜 플레이어를 넣을 때 사용한다. 기본값은 [AudioPoolClickPlayer].
  ///
  /// 인스턴스가 아니라 생성 함수를 받아서, 위젯이 다시 만들어져도(핫 리로드 등)
  /// 플레이어는 Provider가 처음 만들 때 한 번만 생긴다.
  final ClickPlayer Function()? createClickPlayer;
  final SongRepository? songRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MetronomeController(
            clickPlayer: createClickPlayer?.call() ?? AudioPoolClickPlayer(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SetListController(repository: songRepository ?? SongRepository())
                ..load(),
        ),
      ],
      child: MaterialApp(
        theme: buildAppTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
