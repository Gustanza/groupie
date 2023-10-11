import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groupie/softres/constants.dart';

class SearchGroup extends StatefulWidget {
  const SearchGroup({super.key});

  @override
  State<SearchGroup> createState() => _SearchGroupState();
}

class _SearchGroupState extends State<SearchGroup> {
  TextEditingController searchEmCon = TextEditingController();
  FirebaseFirestore storeOBJ = FirebaseFirestore.instance;
  FirebaseAuth authOBJ = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: .5,
        title: CupertinoTextField(
            textCapitalization: TextCapitalization.sentences,
            controller: searchEmCon,
            onChanged: (value) {
              setState(() {});
            },
            placeholder: "Search Group"),
      ),
      body: searchEmCon.text.isEmpty
          ? const Center(
              child: Text(
                "search groups and send request \n easily",
                textAlign: TextAlign.center,
              ),
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection(groupC)
                  .where(nameC, isGreaterThanOrEqualTo: searchEmCon.text)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var data = (snapshot.data as dynamic).docs;
                  if (data.isEmpty) {
                    return const Center(child: Text('Group not found'));
                  }
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 0,
                        child: CupertinoListTile(
                          title: Text(
                            data[index][nameC],
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: TextButton(
                              onPressed: () async {
                                await sendingRequest(data[index].id);
                              },
                              child: const Text('request to join')),
                        ),
                      );
                    },
                  );
                }
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                );
              },
            ),
    );
  }

  Future<void> sendingRequest(String id) async {
    var mimi = authOBJ.currentUser?.email;
    var groupSp = storeOBJ.collection(groupC).doc(id);
    var data = await groupSp.get();
    var mareq = data.data()?[requestC];
    var mareqw = mareq;
    if (!mareq.contains(mimi)) {
      mareqw.add(mimi);
      try {
        await groupSp.update({requestC: mareqw});
        FocusScope.of(context).unfocus();
        mjumbe("Request sent succesfully");
      } catch (err) {
        mjumbe(err.toString());
      }
    } else {
      FocusScope.of(context).unfocus();
      mjumbe("Request already exists");
    }
  }

  mjumbe(String ujumbe) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ujumbe)));
  }
}
