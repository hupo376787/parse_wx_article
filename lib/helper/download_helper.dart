import 'dart:io';
import 'package:flutter/material.dart';

import 'package:parse_wx_article/helper/toast_helper.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

void downloadFileFromUrl(String url, Directory folder) async {
  try {
    var res = await http.get(Uri.parse(url));
    var ext = Uri.parse(url).queryParameters['wx_fmt'];
    var localPath =
        path.join(folder.path, '${DateTime.now().millisecondsSinceEpoch}.$ext');
    debugPrint(localPath);
    var imageFile = File(localPath);

    await imageFile.writeAsBytes(res.bodyBytes);
  } catch (e) {
    showMyToast(e.toString());
  }
}
