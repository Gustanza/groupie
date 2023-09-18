import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groupie/softres/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'members.dart';

class Group extends StatefulWidget {
  final String groupId;
  final String groupName;
  const Group({super.key, required this.groupId, required this.groupName});

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  TextEditingController ujumbeCon = TextEditingController();
  var mimi = FirebaseAuth.instance.currentUser?.email;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: .5,
        centerTitle: true,
        title: Text(widget.groupName),
        actions: [
          IconButton.filled(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SearchToAdd(
                          groupId: widget.groupId,
                        )));
              },
              icon: const Icon(Icons.search)),
          IconButton.filled(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MembersPanel(
                      grpId: widget.groupId, grpName: widget.groupName),
                ));
              },
              icon: const Icon(Icons.person)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(groupC)
                  .doc(widget.groupId)
                  .collection(shats)
                  .orderBy(shatsTime, descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var data = (snapshot.data as dynamic).docs;
                  if (data.isEmpty) {
                    return const Center(
                      child: Text('Start a conversation'),
                    );
                  }
                  return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      reverse: true,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: data[index][shatsSender] == mimi
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 8),
                              constraints: const BoxConstraints(
                                  minHeight: kBottomNavigationBarHeight,
                                  minWidth: kBottomNavigationBarHeight,
                                  maxWidth: 300),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: CupertinoColors.systemGrey),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    data[index][shatsImage] != null
                                        ? GestureDetector(
                                            onTap: () {
                                              showCupertinoDialog(
                                                context: context,
                                                builder: (context) =>
                                                    CupertinoAlertDialog(
                                                  title: Text(
                                                      "${data[index][shatsText]} sold at ${data[index][shatsImagePrice]} TZS"),
                                                  content:
                                                      const CupertinoTextField(
                                                    placeholder: "Amount",
                                                  ),
                                                  actions: [
                                                    CupertinoButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                            color: CupertinoColors
                                                                .destructiveRed),
                                                      ),
                                                    ),
                                                    CupertinoButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text("Buy"),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 6),
                                              child: Image.network(
                                                  data[index][shatsImage]),
                                            ),
                                          )
                                        : const SizedBox(),
                                    Text(
                                      data[index][shatsText],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )
                                  ]),
                            ),
                          ],
                        );
                      });
                }
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoTextField(
              controller: ujumbeCon,
              textCapitalization: TextCapitalization.sentences,
              prefix: IconButton(
                  onPressed: () async {
                    XFile? picha = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (picha != null) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            PhotoSender(grpId: widget.groupId, picha: picha),
                      ));
                    }
                  },
                  icon: const Icon(Icons.camera_alt)),
              suffix: IconButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection(groupC)
                        .doc(widget.groupId)
                        .collection(shats)
                        .add({
                      shatsImage: null,
                      shatsText: ujumbeCon.text,
                      shatsSender: mimi,
                      shatsTime: DateTime.now()
                    });
                    ujumbeCon.clear();
                    FocusScope.of(context).unfocus();
                  },
                  icon: const Icon(Icons.send)),
            ),
          )
        ],
      ),
    );
  }
}

class SearchToAdd extends StatefulWidget {
  final String groupId;

  const SearchToAdd({super.key, required this.groupId});

  @override
  State<SearchToAdd> createState() => _SearchToAddState();
}

class _SearchToAddState extends State<SearchToAdd> {
  TextEditingController searchEmCon = TextEditingController();
  FirebaseFirestore storeOBJ = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: storeOBJ.collection(groupC).doc(widget.groupId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var grpMembaz = (snapshot.data as dynamic).data()[membersC];
          return Scaffold(
            appBar: AppBar(
              elevation: .5,
              title: CupertinoTextField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: searchEmCon,
                  onChanged: (value) {
                    setState(() {});
                  },
                  placeholder: "Search member"),
            ),
            body: searchEmCon.text.isEmpty
                ? const Center(
                    child: Text(
                      "search and add members \n easily",
                      textAlign: TextAlign.center,
                    ),
                  )
                : FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .where("jina", isGreaterThanOrEqualTo: searchEmCon.text)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var data = (snapshot.data as dynamic).docs;
                        if (data.isEmpty) {
                          return const Center(child: Text('User not found'));
                        }
                        return CupertinoListSection.insetGrouped(
                          children: List.generate(
                              data.length,
                              (index) => CupertinoListTile(
                                    title: Text(data[index]["jina"]),
                                    trailing: TextButton(
                                        onPressed: () async {
                                          if (!grpMembaz
                                              .contains(data[index].id)) {
                                            var grpmembers = grpMembaz;
                                            grpmembers.add(data[index].id);
                                            await storeOBJ
                                                .collection(groupC)
                                                .doc(widget.groupId)
                                                .update({membersC: grpmembers});
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content:
                                                        Text("Member Added")));
                                            Navigator.of(context).pop();
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        "Member already exists")));
                                          }
                                        },
                                        child: const Text('Add')),
                                  )),
                        );
                      }
                      return CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      );
                    },
                  ),
          );
        }
        return const Center(child: CupertinoActivityIndicator());
      },
    );
  }
}

class PhotoSender extends StatefulWidget {
  final XFile picha;
  final String grpId;
  const PhotoSender({super.key, required this.grpId, required this.picha});

  @override
  State<PhotoSender> createState() => _PhotoSenderState();
}

class _PhotoSenderState extends State<PhotoSender> {
  var mimi = FirebaseAuth.instance.currentUser?.email;
  TextEditingController nameCon = TextEditingController();
  TextEditingController priceCon = TextEditingController();
  bool amUploading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
              image:
                  DecorationImage(image: FileImage(File(widget.picha.path)))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CupertinoTextField(
                controller: nameCon,
                textCapitalization: TextCapitalization.sentences,
                placeholder: "Item name",
              ),
              const SizedBox(height: 4),
              CupertinoTextField(
                controller: priceCon,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.number,
                placeholder: "Item price",
              ),
              const SizedBox(height: 6),
              CupertinoButton(
                  color: CupertinoColors.systemBlue,
                  onPressed: () async {
                    try {
                      setState(() {
                        amUploading = true;
                      });
                      var idYaPicha = DateTime.now();
                      await FirebaseStorage.instance
                          .ref()
                          .child('products/$idYaPicha')
                          .putFile(File(widget.picha.path))
                          .then((snapshot) async {
                        var url = await snapshot.ref.getDownloadURL();
                        await FirebaseFirestore.instance
                            .collection(groupC)
                            .doc(widget.grpId)
                            .collection(shats)
                            .add({
                          shatsImage: url,
                          shatsImagePrice: priceCon.text,
                          shatsText: nameCon.text,
                          shatsSender: mimi,
                          shatsTime: DateTime.now()
                        });
                        setState(() {
                          amUploading = false;
                        });
                        nameCon.clear();
                        priceCon.clear();
                        FocusScope.of(context).unfocus();
                        Navigator.of(context).pop();
                      });
                    } catch (shida) {
                      setState(() {
                        amUploading = false;
                      });
                      print('oyaaaaaaa: $shida');
                    }
                  },
                  child: amUploading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text("Send"))
            ],
          ),
        ));
  }
}
