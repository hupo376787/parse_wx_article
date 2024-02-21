import 'package:flutter/material.dart';

Future<bool?> showMySimpleDialog(BuildContext context, String msg) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: null,
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              child: const Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            TextButton(
              child: const Text("确定"),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      });
}
