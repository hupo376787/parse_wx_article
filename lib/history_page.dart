import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('历史记录')),
      body: ListView.separated(
        separatorBuilder: (context, index) {
          return const Divider();
        },
        itemCount: box.length,
        itemBuilder: (context, index) {
          return SizedBox(
            height: 32,
            child: InkWell(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(histories[index].index.toString()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(histories[index].timespan),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(histories[index].title),
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
            ),
          );
        },
      ),
    );
  }
}
