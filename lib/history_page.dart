import 'package:flutter/material.dart';
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

    for (var i = db.length - 1; i >= 0; i--) {
      int timespan = double.tryParse(db.keyAt(i).toString())!.toInt();
      var date = DateTime.fromMicrosecondsSinceEpoch(timespan);
      histories
          .add(HistoryModel(date.toString().substring(0, 19), db.getAt(i)));
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
        itemCount: db.length,
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
                      child: Text(histories[index].timespan),
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
