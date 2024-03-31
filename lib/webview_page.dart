import 'package:flutter/material.dart';
import "package:webview_universal/webview_universal.dart";

class MyWebviewPage extends StatefulWidget {
  const MyWebviewPage({Key? key, @required this.inputUrl}) : super(key: key);
  final String? inputUrl;

  @override
  State<MyWebviewPage> createState() => _MyWebviewPageState();
}

class _MyWebviewPageState extends State<MyWebviewPage> {
  WebViewController webViewController = WebViewController();

  @override
  void initState() {
    super.initState();
    task();
  }

  Future<void> task() async {
    await webViewController.init(
      setState: (fn) {},
      context: context,
      uri: Uri.parse(widget.inputUrl!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('浏览器')),
      body: WebView(
        controller: webViewController,
      ),
    );
  }
}
