import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:parse_wx_article/helper/toast_helper.dart';
import 'package:parse_wx_article/helper/dialog_helper.dart';

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:ms_undraw/ms_undraw.dart';
import 'package:lottie/lottie.dart';
import 'package:window_manager/window_manager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WidgetsFlutterBinding.ensureInitialized();
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
    return OKToast(
        child: MaterialApp(
      title: '微信文章图片下载',
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange)),
      home: const MyHomePage(title: '微信文章图片下载'),
    ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final appSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(children: <Widget>[
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: const EdgeInsets.all(4),
            child: IconButton(
                onPressed: () async {
                  bool? res = await showMySimpleDialog(context,
                      '下载目录说明\r\nWindows: 根目录Download文件夹\r\nAndroid: /storage/emulated/0/Download\r\n其他: 没设备没法测试');
                  if (res == null) {
                    debugPrint('取消');
                  } else {
                    debugPrint('确定');
                  }
                },
                icon: const Icon(Icons.settings)),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Lottie.asset('assets/lottie/1708440553399.json',
                  height: appSize.height / 3),
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
                child: FloatingActionButton(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.orange,
                  onPressed: () async {
                    try {
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
                          var res = await http.get(Uri.parse(item));
                          var ext = Uri.parse(item).queryParameters['wx_fmt'];
                          var localPath = path.join(folder.path,
                              '${DateTime.now().millisecondsSinceEpoch}.$ext');
                          debugPrint(localPath);
                          var imageFile = File(localPath);
                          if (res.bodyBytes.length > 50 * 1024) {
                            await imageFile.writeAsBytes(res.bodyBytes);
                            i++;
                          }
                        }

                        showMyToast('下载了$i张图片');
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
              Container(
                padding: const EdgeInsets.only(top: 16),
                child: const Text(
                  '程序自动过滤50KB以下的图片',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            ],
          ),
        )
      ]),
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

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
