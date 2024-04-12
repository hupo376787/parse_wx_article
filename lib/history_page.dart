import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_wx_article/helper/toast_helper.dart';
import 'package:parse_wx_article/main.dart';
import 'package:parse_wx_article/model/history_model.dart';
import 'package:parse_wx_article/webview_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryModel> histories = [];
  @override
  void initState() {
    super.initState();

    for (var i = box.length - 1; i >= 0; i--) {
      var his = HistoryModel.fromJson(box.getAt(i));
      int index = box.length - 1 - his.index;
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
                height: 50,
                child: InkWell(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.grass),
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
              );
            },
          )
        ],
      )),
    );
  }
}
