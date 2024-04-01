import 'package:hive/hive.dart';

// class HistoryModel {
//   HistoryModel(
//       {required this.index,
//       required this.timespan,
//       required this.title,
//       required this.url});

//   factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
//       index: json['index'] as int,
//       timespan: json['timespan'] as String,
//       title: json['title'] as String,
//       url: json['url'] as String);

//   final int index;
//   final String timespan;
//   final String title;
//   final String url;

//   Map<String, dynamic> toJson() =>
//       {'index': index, 'timespan': timespan, 'title': title, 'url': url};
// }

class HistoryModel {
  int index;
  String timespan;
  String title;
  String url;

  HistoryModel(this.index, this.timespan, this.title, this.url);
}

// Can be generated automatically
class HistoryModelAdapter extends TypeAdapter<HistoryModel> {
  @override
  final typeId = 0;

  @override
  HistoryModel read(BinaryReader reader) {
    return reader.read();
    // return HistoryModel(reader.read(0) as int, reader.read(1) as String,
    //     reader.read(2) as String, reader.read(3) as String);
  }

  @override
  void write(BinaryWriter writer, HistoryModel obj) {
    writer.write(HistoryModel(obj.index, obj.timespan, obj.title, obj.url));
  }
}
