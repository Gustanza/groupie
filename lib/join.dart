import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groupie/softres/constants.dart';

class JoinRequests extends StatefulWidget {
  final String groupId;
  const JoinRequests({super.key, required this.groupId});

  @override
  State<JoinRequests> createState() => _JoinRequestsState();
}

class _JoinRequestsState extends State<JoinRequests> {
  FirebaseFirestore storeOBJ = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: .5,
          centerTitle: true,
          title: const Text("Join Requests"),
        ),
        body: StreamBuilder(
          stream: storeOBJ.collection(groupC).doc(widget.groupId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var grpData = (snapshot.data as dynamic).data();
              return ListView.builder(
                itemCount: grpData[requestC].length,
                itemBuilder: (context, index) {
                  return OneCard(
                    grpId: widget.groupId,
                    groupInfo: grpData,
                    email: grpData[requestC][index],
                  );
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
}

class OneCard extends StatelessWidget {
  final String grpId;
  final groupInfo;
  final String email;
  const OneCard(
      {super.key,
      required this.grpId,
      required this.groupInfo,
      required this.email});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection(userc).doc(email).get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var person = (snapshot.data as dynamic).data();
          return Card(
              elevation: 0,
              child: ListTile(
                title: Text(person[usercname]),
                subtitle: Text(person[usercloc]),
                trailing: CupertinoButton(
                  onPressed: () async {
                    var joiners = groupInfo[requestC];
                    var members = groupInfo[membersC];
                    joiners.remove(email);
                    members.add(email);
                    await FirebaseFirestore.instance
                        .collection(groupC)
                        .doc(grpId)
                        .update({requestC: joiners, membersC: members});
                  },
                  child: const Text("Accept"),
                ),
              ));
        }
        return Card(
            elevation: 0,
            child: ListTile(
              title: const Text(""),
              subtitle: const Text(""),
              trailing: CupertinoButton(
                onPressed: () {},
                child: const Text(""),
              ),
            ));
      },
    );
  }
}
