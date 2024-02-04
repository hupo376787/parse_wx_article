import 'package:flutter/material.dart';

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:oktoast/oktoast.dart';
import 'package:system_theme/system_theme.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

final ThemeData theme = ThemeData();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: MaterialApp(
      title: '微信文章图片下载',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange)),
      home: const MyHomePage(title: '微信文章图片下载'),
    ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '请输入微信文章地址',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 32),
              child: FloatingActionButton(
                shape: const CircleBorder(),
                onPressed: () async {
                  try {
                    var status = await Permission.storage.status;
                    if (!status.isGranted) {
                      await Permission.storage.request();
                    }

                    var folder = Directory("");
                    if (Platform.isAndroid) {
                      folder = Directory("/storage/emulated/0/Download");
                    } else if (Platform.isWindows) {
                      folder = Directory(Platform.resolvedExecutable);
                    }

                    //'https://mp.weixin.qq.com/s/a7rWV1a_puEsn6GMKVTa_g'
                    if (!_urlController.text
                        .startsWith('https://mp.weixin.qq.com')) {
                      showToast('请输入正确的微信文章地址，一般是以https://mp.weixin.qq.com开头');
                      return;
                    }
                    var response =
                        await http.get(Uri.parse(_urlController.text));
                    if (response.statusCode == 200) {
                      String body = response.body;
                      var doc = parse(body);
                      doc
                          .getElementsByClassName(
                              'rich_pages js_insertlocalimg wxw-img')
                          .forEach((element) async {
                        var srcUrl = element.attributes['data-src'];
                        debugPrint(srcUrl);

                        // Download Image
                        var res = await http.get(Uri.parse(srcUrl!));
                        var dir = await path_provider
                            .getApplicationDocumentsDirectory();
                        var ext = Uri.parse(srcUrl).queryParameters['wx_fmt'];
                        var localPath = path.join(folder.path,
                            '${DateTime.now().millisecondsSinceEpoch}.$ext');
                        var imageFile = File(localPath);
                        await imageFile.writeAsBytes(res.bodyBytes);
                      });

                      showToast('下载完成');
                    }
                  } catch (ex) {
                    showToast('下载时遇到错误');
                  }
                },
                tooltip: '下载',
                child: const Icon(Icons.download),
              ),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
