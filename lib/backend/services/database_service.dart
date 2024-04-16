import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../models/chat.dart';
import '../models/journallist.dart';
import '../models/message.dart';
import '../models/user_profile.dart';
import '../utils.dart';
import 'auth_service.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference? _usersCollection;
  CollectionReference? _chatsCollection;
  CollectionReference? _journalCollection;

  late AuthService _authService;
  final GetIt _getIt = GetIt.instance;

  DatabaseService() {
    setupCollectionReferences();
    _authService = _getIt.get<AuthService>();
  }

  void setupCollectionReferences() {
    _usersCollection =
        _firebaseFirestore.collection('users').withConverter<UserProfile>(
              fromFirestore: (snapshots, _) =>
                  UserProfile.fromJson(snapshots.data()!),
              toFirestore: (userprofile, _) => userprofile.toJson(),
            );
    _chatsCollection =
        _firebaseFirestore.collection('chats').withConverter<Chat>(
              fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
              toFirestore: (chat, _) => chat.toJson(),
            );
    _journalCollection =
        _firebaseFirestore.collection('journal').withConverter<JournalList>(
              fromFirestore: (snapshot, _) =>
                  JournalList.fromJson(snapshot.data()!),
              toFirestore: (journal, _) => journal.toJson(),
            );
  }

  Future<List<String>> getUSerDetailsfromuid(String uid) async {
    String name = '', pfpUrl = '';

    // Try to get the user document from Firestore
    final docSnapshot = await _usersCollection!.doc(uid).get();

    // Check if document exists
    if (docSnapshot.exists) {
      final userProfile = docSnapshot.data() as UserProfile;
      name = userProfile.name ?? 'Unknown';
      pfpUrl = userProfile.pfpURL ??
          'https://www.google.com/url?sa=i&url=http%3A%2F%2Ft3.gstatic.com%2Flicensed-image%3Fq%3Dtbn%3AANd9GcRlex2yeMomsbkm0qzpHjtPf8j9QLCDPLZ_brREwaQIrpsnwot3sOfn8Qr3ujA92cho&psig=AOvVaw1WVY0CqJU10yvLrfMnn5Gx&ust=1712649769799000&source=images&cd=vfe&opi=89978449&ved=0CAoQjRxqFwoTCNiD3NqTsoUDFQAAAAAdAAAAABAE';
    }

    return [name, pfpUrl];
  }

  Stream<QuerySnapshot<Object?>>? getUserProfiles() {
    return _usersCollection
        ?.where('uid', isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>?;
  }

  Future<void> createUserProfile({
    required UserProfile userProfile,
  }) async {
    await _usersCollection?.doc(userProfile.uid).set(userProfile);
  }

  Future<bool> checkChatExists(String uid1, String uid2) async {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
    final result = await _chatsCollection!.doc(chatId).get();
    if (result != null) {
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatId);
    final chat = Chat(id: chatId, participants: [uid1, uid2], messages: []);
    await docRef.set(chat);
  }

  Future<bool> createJournalEntry(String uid) async {
    final journallist =
        JournalList(uid: _authService.user!.uid, journalEntry: []);
    final result = await _journalCollection!.doc(uid).get();
    if (result.exists) {
      print("journal already initialised");
      return false;
    }
    print("journal now initialised");
    await _journalCollection!.doc(uid).set(journallist);
    return true;
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatId);
    await docRef.update(
      {
        'messages': FieldValue.arrayUnion(
          [
            message.toJson(),
          ],
        ),
      },
    );
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
    return _chatsCollection!.doc(chatId).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }

  Stream<DocumentSnapshot<JournalList>> getJournalData(String uid) {
    print("getJournalData");
    return _journalCollection!.doc(uid).snapshots()
        as Stream<DocumentSnapshot<JournalList>>;
  }

  Future<void> saveJournalEntrynew(String uid, JournalList journalList) async {
    try {
      final docRef = _journalCollection!.doc(uid);
      int length = journalList.journalEntry!.length;
      await docRef.update({
        'journalEntry': FieldValue.arrayUnion(
          [journalList.journalEntry!.elementAt(length - 1).toJson()],
        ),
      });
      print("saved journal");
    } catch (error) {
      // Handle any  errors that occur during the process
      print("Error saving journal entry: $error");
      rethrow;
    }
  }
}
