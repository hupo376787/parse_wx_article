import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:html/parser.dart';

import 'package:parse_wx_article/helper/download_helper.dart';
import 'package:parse_wx_article/helper/toast_helper.dart';

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:parse_wx_article/history_page.dart';
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

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://bb158a849e212c311c4c7d077e9db600@o4506782294671360.ingest.sentry.io/4506782299193344';
    },
    // Init your App.
    appRunner: () => runApp(const MyApp()),
  );
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

late Box db;

class _MyHomePageState extends State<MyHomePage>
    with WidgetsBindingObserver, WindowListener {
  final TextEditingController _urlController = TextEditingController();

  String groupValue = 'article';

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
    await Hive.initFlutter();
    db = await Hive.openBox('history');
  }

  @override
  Widget build(BuildContext context) {
    final appSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
          child: Column(children: <Widget>[
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: const EdgeInsets.all(4),
            child: IconButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingPage()),
                  );
                  // bool? res = await showMySimpleDialog(context,
                  //     '下载目录说明\r\nWindows: 根目录Download\r\nAndroid: /storage/emulated/0/Download\r\n其他: 没设备没法测试');
                  // if (res == null) {
                  //   debugPrint('取消');
                  // } else {
                  //   debugPrint('确定');
                  // }
                },
                icon: const Icon(Icons.settings)),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
            child: IconButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryPage()),
                  );
                },
                icon: const Icon(Icons.list)),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Lottie.asset('assets/lottie/1708440553399.json',
                  height: appSize.height / 2),
              // UnDraw(
              //   height: 1,
              //   color: Colors.orange,
              //   illustration: UnDrawIllustration.cloud_files,
              // ),
              Container(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                child: TextField(
                  controller: _urlController,
                  enableInteractiveSelection: true,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: '请输入微信文章地址',
                      suffixIcon: IconButton(
                          onPressed: () => _urlController.clear(),
                          icon: const Icon(Icons.cancel))),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: SizedBox(
                        width: 160,
                        height: 44,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio(
                              groupValue: groupValue,
                              value: 'article',
                              onChanged: (value) {
                                setState(() {
                                  groupValue = value!;
                                });
                              },
                            ),
                            const Text('文章图片'),
                            const Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Icon(Icons.dashboard),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          groupValue = 'article';
                        });
                      },
                    ),
                    InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: SizedBox(
                        width: 160,
                        height: 44,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio(
                              groupValue: groupValue,
                              value: 'cover',
                              onChanged: (value) {
                                setState(() {
                                  groupValue = value!;
                                });
                              },
                            ),
                            const Text('封面图片'),
                            const Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Icon(Icons.image),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          groupValue = 'cover';
                        });
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16),
                child: FloatingActionButton(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.orange,
                  onPressed: () async {
                    try {
                      //先查找历史记录
                      if (groupValue == 'article' &&
                          db.values.contains(_urlController.text)) {
                        showMyToast('文章图片已经下载过啦');
                        return;
                      }

                      showMyToast('开始下载');
                      debugPrint(groupValue);

                      var status = await Permission.storage.status;
                      if (!status.isGranted) {
                        await Permission.storage.request();
                      }

                      //获取下载目录
                      var folder = Directory("");
                      if (Platform.isAndroid) {
                        folder = Directory("/storage/emulated/0/Download");
                      } else if (Platform.isWindows) {
                        folder = Directory(
                            '${path.dirname(Platform.resolvedExecutable)}/Download');
                        if (!await folder.exists()) {
                          folder.createSync();
                        }
                      } else {
                        folder = await path_provider
                            .getApplicationDocumentsDirectory();
                      }

                      if (_urlController.text.isEmpty ||
                          !_urlController.text
                              .startsWith('https://mp.weixin.qq.com/')) {
                        showMyToast('请输入正确的微信文章地址');
                        return;
                      }
                      var response =
                          await http.get(Uri.parse(_urlController.text));
                      if (response.statusCode == 200) {
                        String body = response.body;
                        int i = 0;

                        if (groupValue == 'article') {
                          var start = "var picturePageInfoList = ";
                          var end = "picturePageInfoList";
                          var startIndex = body.indexOf(start);
                          var endIndex =
                              body.indexOf(end, startIndex + start.length);
                          if (startIndex == -1 && endIndex == -1) {
                            start = "window.picture_page_info_list ";
                            end = "window.appmsgalbuminfo";
                            startIndex = body.indexOf(start);
                            endIndex =
                                body.indexOf(end, startIndex + start.length);
                          }
                          final jsonString = body.substring(
                              startIndex + start.length + 1, endIndex - 2);
                          debugPrint(jsonString);
                          final urlRegExp = RegExp(
                              r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
                          final urlMatches = urlRegExp.allMatches(jsonString);
                          List<String> urls = urlMatches
                              .map((urlMatch) => jsonString.substring(
                                  urlMatch.start, urlMatch.end))
                              .toSet() //List去重
                              .toList();
                          //urls.forEach((x) => print(x));
                          for (var item in urls) {
                            if (!item.contains('wx_fmt=')) continue;

                            debugPrint(item);

                            // Download Image
                            downloadFileFromUrl(item, folder);
                            i++;
                          }

                          showMyToast('下载了$i张图片');

                          //添加数据库
                          db.put(
                              (DateTime.now().microsecondsSinceEpoch)
                                  .toString(),
                              _urlController.text);
                        } else {
                          var doc = parse(body);
                          doc
                              .getElementsByTagName('meta')
                              .where((element) =>
                                  element.attributes['property'] == 'og:image')
                              .forEach((element) async {
                            var item = element.attributes['content'];
                            debugPrint(item);

                            // Download Image
                            downloadFileFromUrl(item!, folder);
                            showMyToast('封面已下载');
                          });
                        }
                      } else {
                        showMyToast('网络错误，请稍后重试');
                      }
                    } catch (ex) {
                      showMyToast('下载时遇到错误');
                    }
                  },
                  tooltip: '下载',
                  child: const Icon(Icons.download),
                ),
              ),
            ],
          ),
        )
      ])),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    debugPrint("当前的应用生命周期状态 : $state");

    if (state == AppLifecycleState.paused) {
      debugPrint("应用进入后台 paused");
    } else if (state == AppLifecycleState.resumed) {
      debugPrint("应用进入前台 resumed");
      var clipp = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipp != null) {
        _urlController.text = clipp.text!;
      }
    } else if (state == AppLifecycleState.inactive) {
      // 应用进入非活动状态 , 如来了个电话 , 电话应用进入前台
      // 本应用进入该状态
      debugPrint("应用进入非活动状态 inactive");
    } else if (state == AppLifecycleState.detached) {
      // 应用程序仍然在 Flutter 引擎上运行 , 但是与宿主 View 组件分离
      debugPrint("应用进入 detached 状态 detached");
    }
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
