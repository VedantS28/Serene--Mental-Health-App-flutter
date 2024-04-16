import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  String? title;
  DateTime? date;
  String? content;

  JournalEntry({
    required this.title,
    required this.date,
    required this.content,
  });

  JournalEntry.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = (json['content']);
    date = (json['date'] as Timestamp).toDate();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['content'] = content;
    data['date'] = date;
    return data;
  }
}
