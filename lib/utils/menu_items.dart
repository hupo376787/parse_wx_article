import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:parse_wx_article/download_page.dart';
import 'package:parse_wx_article/history_page.dart';
import 'package:parse_wx_article/helper/toast_helper.dart';

class MenuItems {
  late List<ContextMenuEntry> entries;
  late int id;

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
          // box.delete(histories
          //     .where((element) => element.url == histories[id].url)
          //     .first
          //     .timespan);
          histories.removeAt(id);
          showMyToast('纪录已删除');
        },
      ),
      MenuItem(
        label: '清空纪录',
        icon: Icons.warning,
        onSelected: () async {
          box.clear();
          histories.clear();
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
}
