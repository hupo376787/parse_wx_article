class HistoryModel {
  HistoryModel(
      {required this.index,
      required this.timespan,
      required this.title,
      required this.url});

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
      index: json['index'] as int,
      timespan: json['timespan'] as String,
      title: json['title'] as String,
      url: json['url'] as String);

  final int index;
  final String timespan;
  final String title;
  final String url;

  Map<String, dynamic> toJson() =>
      {'index': index, 'timespan': timespan, 'title': title, 'url': url};
}
