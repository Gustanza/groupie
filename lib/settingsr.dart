import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var jinalangu = FirebaseAuth.instance.currentUser?.displayName;
  var emailYangu = FirebaseAuth.instance.currentUser?.email;
  var pichaYangu = FirebaseAuth.instance.currentUser?.photoURL;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.5,
        title: const Text('Account Settings'),
      ),
      body: CupertinoListSection.insetGrouped(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(pichaYangu!),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      jinalangu!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: CupertinoColors.systemBlue),
                    ),
                    Text(
                      emailYangu!,
                      style: const TextStyle(
                          fontSize: 16, color: CupertinoColors.destructiveRed),
                    )
                  ],
                )
              ],
            ),
          ),
          CupertinoButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
            },
            child: const Text("Log Out"),
          )
        ],
      ),
    );
  }
}
