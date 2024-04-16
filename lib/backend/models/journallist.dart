import 'journalentry.dart';

class JournalList {
  String? uid;
  List<JournalEntry>? journalEntry;

  JournalList({required this.uid, required this.journalEntry});

  JournalList.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    if (json['journalEntry'] != null) {
      journalEntry = List<JournalEntry>.from(
          json['journalEntry'].map((entry) => JournalEntry.fromJson(entry)));
    } else {
      journalEntry = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['journalEntry'] = journalEntry;
    return data;
  }
}
