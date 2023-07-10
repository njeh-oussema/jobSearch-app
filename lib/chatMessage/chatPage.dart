import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/chatMessage/Widget.dart';
import 'package:frontend/chatMessage/style.dart';
/* import 'package:image/comps/styles.dart';
import 'package:image/comps/widgets.dart'; */

class ChatPage extends StatefulWidget {
  final String id;
  const ChatPage({Key? key, required this.id}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  var roomId;
  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    return Scaffold(
      backgroundColor: Colors.indigo.shade400,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade400,
        title: const Text('John Doe'),
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Chats',
                  style: Styles.h1(),
                ),
                const Spacer(),
                Text(
                  'Last seen: 04:50',
                  style: Styles.h1().copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.white70),
                ),
                const Spacer(),
                const SizedBox(
                  width: 50,
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: Styles.friendsBox(),
              child: StreamBuilder(
                  stream: firestore.collection('rooms').snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.docs.isNotEmpty) {
                        List<QueryDocumentSnapshot?> alldata = snapshot
                            .data!.docs
                            .where((element) =>
                                element['users'].contain(widget.id) &&
                                element['users'].contain(
                                    FirebaseAuth.instance.currentUser!.uid))
                            .toList();
                        QueryDocumentSnapshot? data =
                            alldata.isNotEmpty ? alldata.first : null;

                        if (data != null) {
                          roomId = data.id;
                        }
                        return data == null
                            ? Container()
                            : StreamBuilder(
                                stream: data.reference
                                    .collection('message')
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snap) {
                                  return !snap.hasData
                                      ? Container()
                                      : ListView.builder(
                                          itemCount: snap.data!.docs.length,
                                          reverse: true,
                                          itemBuilder: (context, i) {
                                            return ChatWidgets.messagesCard(
                                                i,
                                                'Firebase projects are containers for your app Apps in a project share features like Real-time Database and Analytics',
                                                '04:51 pm');
                                          },
                                        );
                                });
                      } else {
                        return Text(
                          'No conversation found',
                          style: Styles.h1().copyWith(color: Colors.indigo),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.indigo),
                      );
                    }
                  }),
            ),
          ),
          Container(
            color: Colors.red,
            child: ChatWidgets.messageField(onSubmit: (controller) {
              // controller.clear();
              if (roomId != null) {
              } else {
                Map<String, dynamic> data = {
                  'message': controller.text.trim(),
                  'sensBy': FirebaseAuth.instance.currentUser!.uid,
                  'datetime': DateTime.now(),
                };

                firestore.collection('rooms').add({
                  'users': [widget.id, FirebaseAuth.instance.currentUser!.uid],
                }).then((value) async {
                  value.collection('message').add(data);
                });
              }
            }),
          )
        ],
      ),
    );
  }
}
