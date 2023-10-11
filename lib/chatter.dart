import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groupie/softres/constants.dart';
import 'package:image_picker/image_picker.dart';

class GroupDef extends StatefulWidget {
  const GroupDef({super.key});

  @override
  State<GroupDef> createState() => _GroupDefState();
}

class _GroupDefState extends State<GroupDef> {
  TextEditingController ujumbeCon = TextEditingController();
  var emailYangu = FirebaseAuth.instance.currentUser?.email;
  var jinaLangu = FirebaseAuth.instance.currentUser?.displayName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: .5,
        centerTitle: true,
        title: Text(groupDefault),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(groupC)
                  .doc(groupDefaultId)
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
                          mainAxisAlignment:
                              data[index][shatsSender] == emailYangu
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              margin: const EdgeInsets.only(bottom: 6),
                              constraints: const BoxConstraints(
                                  minHeight: kBottomNavigationBarHeight,
                                  minWidth: kBottomNavigationBarHeight,
                                  maxWidth: 300),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: CupertinoColors.systemGrey),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      data[index][shatsSender] == emailYangu
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data[index][shatsText],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    data[index][shatsSenderName] != null
                                        ? Text(
                                            data[index][shatsSenderName],
                                          )
                                        : const SizedBox(),
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
              suffix: IconButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection(groupC)
                        .doc(groupDefaultId)
                        .collection(shats)
                        .add({
                      shatsText: ujumbeCon.text,
                      shatsSenderName: jinaLangu,
                      shatsSender: emailYangu,
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
