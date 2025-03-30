import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_wx_article/download_page.dart';
import 'package:parse_wx_article/helper/toast_helper.dart';
import 'package:parse_wx_article/main.dart';
import 'package:parse_wx_article/model/history_model.dart';
import 'package:parse_wx_article/utils/menu_items.dart';
import 'package:parse_wx_article/webview_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

List<HistoryModel> histories = [];
late List<ContextMenuEntry> entries;
late int id;

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    histories.clear();

    for (var i = box.length - 1; i >= 0; i--) {
      var his = HistoryModel.fromJson(box.getAt(i));
      int index = box.length - i;
      int timespan = double.tryParse(his.timespan)!.toInt();
      var date = DateTime.fromMicrosecondsSinceEpoch(timespan);
      histories.add(HistoryModel(
          index: index,
          timespan: date.toString().substring(0, 19),
          title: his.title,
          url: his.url));
    }
  }

  Widget getWidget() {
    if (box.isEmpty) {
      return Column(
        children: [
          Lottie.asset("assets/lottie/oops.json", repeat: true, height: 320),
          const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Oops，你还没有下载记录',
                style: TextStyle(fontSize: 18),
              ))
        ],
      );
    } else {
      return Column(
        children: [
          Lottie.asset("assets/lottie/congratulations.json",
              repeat: true, height: 320),
          Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '太好了，你已经下载了${box.length}条记录~',
                style: const TextStyle(fontSize: 18),
              ))
        ],
      );
    }
  }

  void initTVMenu() {
    entries = <ContextMenuEntry>[
      MenuItem(
        label: '复制链接',
        icon: Icons.copy,
        onSelected: () {
          Clipboard.setData(ClipboardData(text: histories[id].url));
          showMyToast('链接🔗已复制');
        },
      ),
      MenuItem(
        label: '删除纪录',
        icon: Icons.delete,
        onSelected: () async {
          var b = box
              .getRange(0, box.length)
              .where((element) =>
                  HistoryModel.fromJson(element).url == histories[id].url)
              .first;
          box.delete(HistoryModel.fromJson(b).timespan);
          setState(() {
            histories.removeAt(id);
          });
          showMyToast('纪录已删除');
        },
      ),
      MenuItem(
        label: '清空纪录',
        icon: Icons.warning,
        onSelected: () async {
          box.clear();
          setState(() {
            histories.clear();
          });
          showMyToast('纪录已清空');
        },
      )
    ];
  }

//initialize a context menu
  ContextMenu dynamicMenu(int index) {
    initTVMenu();
    id = index;

    return ContextMenu(
      entries: entries,
      padding: const EdgeInsets.all(0.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('历史记录')),
      body: SingleChildScrollView(
          child: Column(
        children: [
          getWidget(),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) {
              return const Divider();
            },
            itemCount: box.length,
            itemBuilder: (context, index) {
              return SizedBox(
                height: 60,
                child: ContextMenuRegion(
                  contextMenu: dynamicMenu(index),
                  onItemSelected: (value) {
                    debugPrint(index.toString());
                  },
                  child: InkWell(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.grass,
                              color: Colors.green,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                            child: Text(histories[index].index.toString()),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text(histories[index].timespan),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Text(histories[index].title),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  histories[index].url,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyWebviewPage(
                                  inputUrl: histories[index].url,
                                )),
                      );
                    },
                    onLongPress: () {
                      Clipboard.setData(
                          ClipboardData(text: histories[index].url));
                      showMyToast('链接🔗已复制');
                    },
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                box.clear();
                setState(() {
                  histories.clear();
                });
                showMyToast('纪录已清空');
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white),
              child: const Text('清空记录'),
            ),
          )
        ],
      )),
    );
  }
}
