import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../models/chat.dart';
import '../models/journalentry.dart';
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
        _firebaseFirestore.collection('journal').withConverter<JournalEntry>(
              fromFirestore: (snapshot, _) =>
                  JournalEntry.fromJson(snapshot.data()!),
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

  Future<void> saveJournalEntry(String uid, JournalEntry journalEntry) async {
    try {
      // Create a reference to the user's journal entry document
      DocumentReference journalDocRef = _journalCollection!.doc(uid);

      // Get the existing journal entries or create a new list if it doesn't exist
      List<JournalEntry> existingEntries = [];
      final docSnapshot = await journalDocRef.get();
      if (docSnapshot.exists) {
        existingEntries = (docSnapshot.data() as List<dynamic>)
            .map((entryJson) => JournalEntry.fromJson(entryJson))
            .toList();
      }

      // Add the new journal entry to the list
      existingEntries.add(journalEntry);

      // Update the document with the updated list of journal entries
      await journalDocRef
          .set(existingEntries.map((entry) => entry.toJson()).toList());
    } catch (error) {
      // Handle any errors that occur during the process
      print("Error saving journal entry: $error");
      rethrow;
    }
  }

  Future<void> saveJournalEntrynew(
      String uid, JournalEntry journalEntry) async {
    try {
      // Create a reference to the user's journal entries collection
      final docRef = _journalCollection!.doc(uid);

      // Add the new journal entry to the collection
      await docRef.set(journalEntry);
      print("saved journal");
    } catch (error) {
      // Handle any  errors that occur during the process
      print("Error saving journal entry: $error");
      rethrow;
    }
  }

  Future<List<JournalEntry>> getAllJournalEntriesForUID(String uid) async {
    try {
      // Create a reference to the user's journal entries collection
      CollectionReference journalEntriesCollection =
          _journalCollection!.doc(uid).collection('entries');

      // Retrieve all documents from the collection
      QuerySnapshot querySnapshot = await journalEntriesCollection.get();

      // Convert the documents to JournalEntry objects
      List<JournalEntry> entries = querySnapshot.docs.map((doc) {
        return JournalEntry.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      print(entries);
      print("retrieved");
      return entries;
    } catch (error) {
      // Handle any errors that occur during the process
      print("Error retrieving journal entries: $error");
      rethrow;
    }
  }
}
