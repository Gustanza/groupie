import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groupie/join.dart';
import 'package:groupie/softres/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'members.dart';

class Group extends StatefulWidget {
  final String groupId;
  final List groupAdmin;
  final String groupName;
  final List groupJoinR;
  final List groupMembers;
  const Group(
      {super.key,
      required this.groupId,
      required this.groupAdmin,
      required this.groupName,
      required this.groupJoinR,
      required this.groupMembers});

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  TextEditingController ujumbeCon = TextEditingController();
  TextEditingController popCon = TextEditingController();
  var emailYangu = FirebaseAuth.instance.currentUser?.email;
  var jinaLangu = FirebaseAuth.instance.currentUser?.displayName;
  bool loaded = false;
  var groupdata;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: .5,
        title: Text(widget.groupName),
        actions: [
          widget.groupAdmin.contains(emailYangu)
              ? IconButton.filled(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SearchToAdd(
                              groupId: widget.groupId,
                            )));
                  },
                  icon: const Icon(Icons.search))
              : const SizedBox(),
          IconButton.filled(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MembersPanel(
                      grpId: widget.groupId, grpName: widget.groupName),
                ));
              },
              icon: const Icon(Icons.person)),
          widget.groupAdmin.contains(emailYangu)
              ? IconButton.filled(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          JoinRequests(groupId: widget.groupId),
                    ));
                  },
                  icon: const Icon(Icons.notifications))
              : const SizedBox(),
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
                  groupdata = (snapshot.data as dynamic).docs;
                  if (groupdata.isEmpty) {
                    return const Center(
                      child: Text('Start a conversation'),
                    );
                  }
                  return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      reverse: true,
                      itemCount: groupdata.length,
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment:
                              groupdata[index][shatsSender] == emailYangu
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            Container(
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
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    groupdata[index][shatsImage] != null
                                        ? GestureDetector(
                                            onTap: () {
                                              showCupertinoDialog(
                                                context: context,
                                                builder: (context) =>
                                                    CupertinoAlertDialog(
                                                  title: Text(
                                                      "${groupdata[index][shatsText]} sold at ${groupdata[index][shatsImagePrice]} TZS"),
                                                  content: CupertinoTextField(
                                                    controller: popCon,
                                                    keyboardType:
                                                        TextInputType.number,
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
                                                        var keyPrice =
                                                            int.parse(
                                                                popCon.text);
                                                        var actualPrice =
                                                            int.parse(groupdata[
                                                                    index][
                                                                shatsImagePrice]);
                                                        if (keyPrice <
                                                            actualPrice) {
                                                          mesenja(
                                                              'Insufficient Amount');
                                                        } else {
                                                          mesenja(
                                                              'Purchased Succesfully');
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
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
                                                  groupdata[index][shatsImage]),
                                            ),
                                          )
                                        : const SizedBox(),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            groupdata[index][shatsText],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          groupdata[index][shatImageDesc] !=
                                                  null
                                              ? Text(
                                                  groupdata[index]
                                                      [shatImageDesc],
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                )
                                              : const SizedBox(),
                                          groupdata[index][shatsSenderName] !=
                                                  null
                                              ? Text(
                                                  groupdata[index]
                                                      [shatsSenderName],
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
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
          widget.groupAdmin.contains(emailYangu)
              ? Padding(
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
                              builder: (context) => PhotoSender(
                                  grpId: widget.groupId, picha: picha),
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
                            shatImageDesc: null,
                            shatsImagePrice: null,
                            shatsSenderName: jinaLangu,
                            shatsText: ujumbeCon.text,
                            shatsSender: emailYangu,
                            shatsTime: DateTime.now()
                          });
                          ujumbeCon.clear();
                          FocusScope.of(context).unfocus();
                        },
                        icon: const Icon(Icons.send)),
                  ),
                )
              : const SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Card(
                    child: Center(
                      child: Text(
                        'only admins can send message',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  mesenja(String ujumbe) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ujumbe)));
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
  var emailYangu = FirebaseAuth.instance.currentUser?.email;
  var jinaLangu = FirebaseAuth.instance.currentUser?.displayName;
  TextEditingController nameCon = TextEditingController();
  TextEditingController descCon = TextEditingController();
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
                controller: descCon,
                textCapitalization: TextCapitalization.sentences,
                placeholder: "Item description",
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
                          shatImageDesc: descCon.text,
                          shatsImagePrice: priceCon.text,
                          shatsText: nameCon.text,
                          shatsSenderName: jinaLangu,
                          shatsSender: emailYangu,
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
                      ? const CupertinoActivityIndicator(
                          color: Colors.white,
                        )
                      : const Text("Send"))
            ],
          ),
        ));
  }
}
