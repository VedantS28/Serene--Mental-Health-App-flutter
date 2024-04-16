import 'dart:io';
import 'package:get_it/get_it.dart';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mental_health/backend/services/alert_service.dart';
import 'package:mental_health/consts.dart';
import 'package:vibration/vibration.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_gemini/flutter_gemini.dart' as Geminis;

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

List<ChatMessage> messages = [];

class _ChatbotScreenState extends State<ChatbotScreen> {

  final ScrollController _scrollController = ScrollController();
  late final GenerativeModel _model;
  late final ChatSession _chat;
  bool typing = false;
  late final List<Content> history;
  final gemini = Geminis.Gemini.instance;

  final GetIt _getIt = GetIt.instance;
  late AlertService _alertService;

  ChatUser currentUser = ChatUser(
    id: '0',
    firstName: 'User',
  );
  ChatUser otherUser = ChatUser(
    id: '1',
    firstName: 'Helper',
  );

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: GEMINI_API_KEY,
    );
    _chat = _model.startChat();
    history = _chat.history.toList();
    print(history);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Helper"),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      currentUser: currentUser,
      onSend: (ChatMessage m) async {
        await sendInput(m);
      },
      messages: messages,
      inputOptions: InputOptions(
        alwaysShowSend: true,
        autocorrect: true,
        inputDecoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.deepPurple, width: 1),
            borderRadius: BorderRadius.circular(42),
          ),
        ),
        trailing: [
          IconButton(
            onPressed: () async {
              sendImage(context);
            },
            icon: const Icon(Icons.image),
          ),
        ],
      ),
      typingUsers: typing == true ? [otherUser] : [],
      messageOptions: MessageOptions(
        onLongPressMessage: (p0) async {
          _triggerVibration();
          Clipboard.setData(ClipboardData(text: p0.text));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Message copied"),
            ),
          );
        },
      ),
    );
  }

  Future<void> sendImage(BuildContext context) async {
    try {
      final ImagePicker imgpicker = ImagePicker();
      XFile? xFile = await imgpicker.pickImage(source: ImageSource.gallery);
      String? input;

      if (xFile != null) {
        showDialog(
          context: context,
          builder: ((context) {
            TextEditingController controller = TextEditingController();
            GlobalKey<FormState> _formKey = GlobalKey<FormState>();

            return AlertDialog(
              title: const Text("Enter your message"),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        height: MediaQuery.of(context).size.height / 3,
                        child: Image.file(
                          File(xFile.path),
                          fit: BoxFit.contain,
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: controller,
                          autofocus: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      setState(() {
                        input = controller.text;
                        typing = true;
                      });
                      ChatMessage message = ChatMessage(
                        user: currentUser,
                        createdAt: DateTime.now(),
                        text: input!,
                        medias: [
                          ChatMedia(
                              url: xFile.path,
                              fileName: '',
                              type: MediaType.image),
                        ],
                      );
                      setState(() {
                        messages.insert(0, message);
                      });
                      Navigator.of(context).pop();

                      List<Uint8List>? images;
                      if (xFile.path != null) {
                        images = [File(xFile.path).readAsBytesSync()];
                      }

                      String? res;
                      await gemini
                          .textAndImage(text: controller.text, images: images!)
                          .then((value) {
                        res = value?.content?.parts?.last.text;
                        print(res);
                        print(value?.content?.parts?.last.text ?? '');
                      }).catchError(
                        (e) => print(
                          'textAndImageInput: $e',
                        ),
                      );

                      ChatMessage response = ChatMessage(
                        user: otherUser,
                        createdAt: DateTime.now(),
                        text: res!,
                      );
                      setState(() {
                        messages.insert(0, response);
                        controller.clear();
                        typing = false;
                      });
                    }
                  },
                  child: const Text("Send"),
                ),
              ],
            );
          }),
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> sendInput(ChatMessage m) async {
    _triggerVibration();
    setState(() {
      messages.insert(0, m);
      typing = true;
    });
    String? res;
    final response = await _chat.sendMessage(
      Content.text(m.text),
    );
    res = response.text;
    if (res == null) {
      _alertService.showToast(text: "Empty Response", icon: Icons.error);
      print('Empty response.');
      return;
    } else {
      setState(() {
        _scrollDown();
      });
    }

    setState(() {
      messages.insert(
        0,
        ChatMessage(user: otherUser, createdAt: DateTime.now(), text: res!),
      );
      typing = false;
    });
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  void _triggerVibration() {
    Vibration.vibrate(duration: 70, amplitude: 70);
  }
}
