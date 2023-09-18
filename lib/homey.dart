import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groupie/group.dart';
import 'package:groupie/softres/constants.dart';

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
          onPressed: () {},
          child: const Text("Admins"),
        ),
        actions: [
          IconButton.filled(
              onPressed: groupOptions, icon: const Icon(Icons.add)),
          IconButton.filled(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout))
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
                                groupName: data[index]['name'])));
                      },
                      title: Text(data[index]['name']))),
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
                    onPressed: createGroup,
                    child: const Text('Create members group')),
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
                      'name': groupCon.text,
                      'admin': myMail,
                      'members': [myMail]
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
