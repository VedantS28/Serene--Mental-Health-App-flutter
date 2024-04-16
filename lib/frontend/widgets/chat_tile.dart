import 'package:flutter/material.dart';

import '../../backend/models/user_profile.dart';

// ignore: must_be_immutable
class ChatTile extends StatelessWidget {
  final UserProfile userProfile;
  Function onTap;
  ChatTile({super.key, required this.userProfile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        dense: false,
        leading: CircleAvatar(
          foregroundImage: NetworkImage(userProfile.pfpURL!),
        ),
        title: Text(userProfile.name!),
        onTap: () {
          onTap();
        },
      ),
    );
  }
}
