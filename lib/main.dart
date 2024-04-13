import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:html/parser.dart';
import 'package:parse_wx_article/download_page.dart';

import 'package:parse_wx_article/helper/download_helper.dart';
import 'package:parse_wx_article/helper/toast_helper.dart';

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:parse_wx_article/history_page.dart';
import 'package:parse_wx_article/model/history_model.dart';
import 'package:parse_wx_article/setting_page.dart';
import 'package:parse_wx_article/splash_screen.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:lottie/lottie.dart';
import 'package:window_manager/window_manager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:theme_manager/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // 必须加上这一行。
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
        size: Size(1280, 720),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        title: '微信文章图片下载');
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  await initHive();

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://bb158a849e212c311c4c7d077e9db600@o4506782294671360.ingest.sentry.io/4506782299193344';
    },
    // Init your App.
    appRunner: () => runApp(const MyApp()),
  );
}

Future initHive() async {
  final dir = await path_provider.getApplicationDocumentsDirectory();
  Hive.defaultDirectory = dir.path;
}

final ThemeData theme = ThemeData();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeManager(
        defaultBrightnessPreference: BrightnessPreference.light,
        data: (Brightness brightness) => ThemeData(
              primarySwatch: Colors.orange,
              brightness: brightness,
            ),
        themedBuilder: (BuildContext context, ThemeState state) {
          return MaterialApp(
              title: '微信文章图片下载',
              builder: BotToastInit(),
              navigatorObservers: [BotToastNavigatorObserver()],
              theme: state.themeData,
              home: const SplashScreen());
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with WidgetsBindingObserver, WindowListener {
  int bottomNavIndex = 0;
  final iconList = <IconData>[Icons.home, Icons.history, Icons.settings];
  static const List<Widget> pages = [
    DownloadPage(),
    HistoryPage(),
    SettingPage()
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    windowManager.addListener(this);
    _init();

    initDb();
  }

  void _init() async {
    // 添加此行以覆盖默认关闭处理程序
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.setPreventClose(true);
    }
    setState(() {});
  }

  void initDb() async {
    Hive.registerAdapter("HistoryModel", (json) => HistoryModel.fromJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AnimatedBottomNavigationBar(
          icons: iconList,
          activeIndex: bottomNavIndex,
          onTap: (index) {
            setState(() {
              bottomNavIndex = index;
            });
          }),
      body: pages.elementAt(bottomNavIndex),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  bool isShowing = false;
  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && !isShowing) {
      if (!mounted) return;
      isShowing = true;

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('确定关闭程序?'),
            actions: [
              TextButton(
                child: const Text('取消'),
                onPressed: () {
                  isShowing = false;
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('确定'),
                onPressed: () async {
                  isShowing = true;
                  Navigator.of(context).pop();
                  await windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    windowManager.removeListener(this);
  }
}
