import 'journalentry.dart';

class JournalList {
  String? uid;
  List<JournalEntry>? journalEntry;

  JournalList({required this.uid, required this.journalEntry});

  JournalList.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    journalEntry = json['journalEntry'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['journalEntry'] = journalEntry;
    return data;
  }
}
