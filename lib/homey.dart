import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groupie/chatter.dart';
import 'package:groupie/group.dart';
import 'package:groupie/search.dart';
import 'package:groupie/softres/constants.dart';

import 'settingsr.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  User? currenUser = FirebaseAuth.instance.currentUser;
  String? mimi = FirebaseAuth.instance.currentUser?.email;
  TextEditingController groupCon = TextEditingController();
  String? profilejina;
  String? profilepicha;
  String? myMail;
  @override
  void initState() {
    profilejina = currenUser?.displayName;
    profilepicha = currenUser?.photoURL;
    myMail = currenUser?.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: .5,
        centerTitle: true,
        title: const Text('Groupie'),
        leadingWidth: 100,
        leading: CupertinoButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const GroupDef(),
              ));
            },
            child: const Text("Chat")),
        actions: [
          IconButton.filled(
              onPressed: groupOptions, icon: const Icon(Icons.add)),
          IconButton.filled(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SearchGroup(),
                ));
              },
              icon: const Icon(Icons.search)),
          IconButton.filled(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ));
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(groupC)
            .where(membersC, arrayContains: mimi)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = (snapshot.data as dynamic).docs;
            if (data.isEmpty) {
              return const Center(
                child: Text("You have no group(s) yet!"),
              );
            }
            return CupertinoListSection.insetGrouped(
              children: List.generate(
                  data.length,
                  (index) => CupertinoListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Group(
                                  groupId: data[index].id,
                                  groupAdmin: data[index][adminC],
                                  groupName: data[index][nameC],
                                  groupJoinR: data[index][requestC],
                                  groupMembers: data[index][membersC],
                                )));
                      },
                      title: Text(data[index][nameC]))),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  groupOptions() {
    showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                    onPressed: createGroup, child: const Text('CREATE GROUP')),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('CANCEL'),
              ),
            ));
  }

  createGroup() {
    Navigator.of(context).pop();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Create Group'),
        content: CupertinoTextField(
          controller: groupCon,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: CupertinoColors.destructiveRed),
              )),
          TextButton(
              onPressed: () async {
                if (groupCon.text.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance.collection(groupC).add({
                      nameC: groupCon.text,
                      adminC: [myMail],
                      requestC: [],
                      membersC: [myMail]
                    });
                    groupCon.clear();
                    Navigator.of(context).pop();
                  } catch (err) {
                    mesenja(err.toString());
                  }
                } else {
                  mesenja('Provide name for the group');
                }
              },
              child: const Text('Create'))
        ],
      ),
    );
  }

  mesenja(String ujumbe) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ujumbe)));
  }
}
