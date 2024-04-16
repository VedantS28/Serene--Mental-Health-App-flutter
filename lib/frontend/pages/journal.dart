import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mental_health/backend/services/auth_service.dart';
import 'package:mental_health/backend/services/database_service.dart';

import '../../backend/models/journalentry.dart';

class JournalPage extends StatefulWidget {
  @override
  _JournalPageState createState() => _JournalPageState();
}

List<JournalEntry> entries = [];

class _JournalPageState extends State<JournalPage> {
  late AuthService authService;
  late DatabaseService databaseService;
  GetIt getIt = GetIt.instance;

  // List<JournalEntry> entries = [];

  @override
  void initState() {
    super.initState();
    authService = getIt.get<AuthService>();
    databaseService = getIt.get<DatabaseService>();
    databaseService
        .getAllJournalEntriesForUID(authService.user!.uid)
        .then((value) => entries = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Journal',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color.fromRGBO(255, 255, 255, 1),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      ),
      backgroundColor: const Color.fromARGB(
          255, 0, 0, 0), // Changing Scaffold background color
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: const Color.fromRGBO(255, 255, 255, 1),
        ),
        margin: const EdgeInsets.all(20.0),
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(entries[index].title!),
              subtitle: Text(entries[index].date.toString()),
              onTap: () {
                // Navigate to a page to view the full journal entry
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JournalEntryViewPage(
                      entry: entries[index],
                      onDelete: () {
                        _deleteEntry(index);
                      },
                      onUpdate: (updatedEntry) {
                        _updateEntry(updatedEntry, index);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.all(15),
        color: Colors.transparent,
        child: FloatingActionButton(
          elevation: 100,
          splashColor: Colors.white,
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          onPressed: () {
            // Navigate to the page to create a new journal entry
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewJournalEntryPage(),
              ),
            ).then((newEntry) {
              if (newEntry != null) {
                setState(() {
                  entries.add(newEntry);
                });
              }
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _deleteEntry(int index) {
    setState(() {
      entries.removeAt(index);
    });
  }

  void _updateEntry(JournalEntry updatedEntry, int index) {
    setState(() {
      entries[index] = updatedEntry;
    });
  }
}

class NewJournalEntryPage extends StatefulWidget {
  @override
  State<NewJournalEntryPage> createState() => _NewJournalEntryPageState();
}

class _NewJournalEntryPageState extends State<NewJournalEntryPage> {
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _contentController = TextEditingController();

  late DatabaseService _databaseService;

  late AuthService _authService;

  GetIt getIt = GetIt.instance;

  @override
  void initState() {
    super.initState();
    _databaseService = getIt.get<DatabaseService>();
    _authService = getIt.get<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Entry',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(255, 255, 255, 1),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
        leading: IconButton(
          // Customizing the back button
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); // Navigate back to previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _contentController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Content',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.black),
              ),
              onPressed: () {
                if (_titleController.text.isNotEmpty &&
                    _contentController.text.isNotEmpty) {
                  _databaseService.saveJournalEntrynew(
                      _authService.user!.uid,
                      JournalEntry(
                        title: _titleController.text,
                        date: DateTime.now(),
                        content: _contentController.text,
                      ));
                  Navigator.pop(
                    context,
                    JournalEntry(
                      title: _titleController.text,
                      date: DateTime.now(),
                      content: _contentController.text,
                    ),
                  );
                } else {
                  // Show a snackbar indicating that title and content are required
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Title and content are required.'),
                    ),
                  );
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JournalEntryViewPage extends StatelessWidget {
  final JournalEntry entry;
  final Function onDelete;
  final Function(JournalEntry) onUpdate;

  const JournalEntryViewPage({
    required this.entry,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title!),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _confirmDelete(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _navigateToUpdateJournalEntryPage(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              entry.content!,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Date: ${entry.date}',
              style: const TextStyle(fontSize: 14.0),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this entry?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                onDelete();
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _navigateToUpdateJournalEntryPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateJournalEntryPage(entry: entry),
      ),
    ).then((updatedEntry) {
      if (updatedEntry != null) {
        onUpdate(updatedEntry);
      }
    });
  }
}

class UpdateJournalEntryPage extends StatefulWidget {
  final JournalEntry entry;
  final TextEditingController _titleController;
  final TextEditingController _contentController;

  UpdateJournalEntryPage({required this.entry})
      : _titleController = TextEditingController(text: entry.title),
        _contentController = TextEditingController(text: entry.content);

  @override
  State<UpdateJournalEntryPage> createState() => _UpdateJournalEntryPageState();
}

class _UpdateJournalEntryPageState extends State<UpdateJournalEntryPage> {
  late DatabaseService _databaseService;

  late AuthService _authService;

  GetIt getIt = GetIt.instance;

  @override
  void initState() {
    super.initState();
    _databaseService = getIt.get<DatabaseService>();
    _authService = getIt.get<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Journal Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: widget._titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: widget._contentController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Content',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                _databaseService.saveJournalEntrynew(
                    _authService.user!.uid,
                    JournalEntry(
                        title: widget._titleController.text,
                        date: DateTime.now(),
                        content: widget._contentController.text));
                _updateEntry(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateEntry(BuildContext context) {
    if (widget._titleController.text.isNotEmpty &&
        widget._contentController.text.isNotEmpty) {
      JournalEntry updatedEntry = JournalEntry(
        title: widget._titleController.text,
        date: DateTime.now(),
        content: widget._contentController.text,
      );
      Navigator.pop(context, updatedEntry);
    } else {
      // Show a snackbar indicating that title and content are required
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title and content are required.'),
        ),
      );
    }
  }
}
