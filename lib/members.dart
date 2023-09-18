import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groupie/softres/constants.dart';

class MembersPanel extends StatelessWidget {
  final String grpId;
  final String grpName;

  const MembersPanel({super.key, required this.grpId, required this.grpName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: .5,
        title: Text("$grpName members"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(groupC)
              .doc(grpId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = (snapshot.data as dynamic).data()[membersC];
              return CupertinoListSection(
                children: List.generate(data.length,
                    (index) => CupertinoListTile(title: Text(data[index]))),
              );
            }
            return const Center(child: CupertinoActivityIndicator());
          },
        ),
      ),
    );
  }
}
