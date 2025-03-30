import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:html/parser.dart';

import 'package:parse_wx_article/helper/download_helper.dart';
import 'package:parse_wx_article/helper/toast_helper.dart';

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:parse_wx_article/model/history_model.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:lottie/lottie.dart';
import 'package:window_manager/window_manager.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

final Box box = Hive.box(name: "HistoryBox");

class _DownloadPageState extends State<DownloadPage>
    with
        AutomaticKeepAliveClientMixin<DownloadPage>,
        WidgetsBindingObserver,
        WindowListener {
  final TextEditingController _urlController = TextEditingController();

  String groupValue = 'article';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    windowManager.addListener(this);
  }

  @override
  Widget build(BuildContext context) {
    final appSize = MediaQuery.of(context).size;

    super.build(context);
    return SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
          const SizedBox(height: 50),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Lottie.asset('assets/lottie/sun.json',
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
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
                        if (_urlController.text.isEmpty ||
                            !_urlController.text
                                .startsWith('https://mp.weixin.qq.com/')) {
                          showMyToast('请输入正确的微信文章地址');
                          return;
                        }

                        //查找历史记录
                        for (int i = 0; i <= box.length - 1; i++) {
                          var value = HistoryModel.fromJson(box.getAt(i));
                          if (groupValue == 'article' &&
                              value.url == _urlController.text) {
                            showMyToast('文章图片已经下载过啦');
                            return;
                          }
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

                        var headers = {
                          'User-Agent':
                              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                        };
                        var response = await http.get(
                            Uri.parse(_urlController.text),
                            headers: headers);
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

                            //获取标题
                            var doc = parse(body);
                            String? title;
                            doc
                                .getElementsByTagName('meta')
                                .where((element) =>
                                    element.attributes['property'] ==
                                    'og:title')
                                .forEach((element) async {
                              title = element.attributes['content'];
                              debugPrint(title);
                            });

                            //添加数据库
                            try {
                              var timespan =
                                  (DateTime.now().microsecondsSinceEpoch)
                                      .toString();
                              var his = HistoryModel(
                                  index: box.length,
                                  timespan: timespan,
                                  title: title!,
                                  url: _urlController.text);
                              box.put(timespan, his);
                            } catch (error) {
                              debugPrint(error.toString());
                            }
                          } else {
                            var doc = parse(body);
                            doc
                                .getElementsByTagName('meta')
                                .where((element) =>
                                    element.attributes['property'] ==
                                    'og:image')
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
        ]));
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
}
