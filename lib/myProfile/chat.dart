import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Widgets/bottom_nav_bar.dart';

final _firestore = FirebaseFirestore.instance;
late User signedInUser;

class ChatScreen extends StatefulWidget {
  static const String screenRoute = 'chat_screen';
  final String nomreceiver;
  final String imageReceiver;

  final String idReceiver;

  const ChatScreen({
    Key? key,
    required this.nomreceiver,
    required this.imageReceiver,
    required this.idReceiver,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String? messageText;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    print("id receiver" + " " + widget.idReceiver);
    print("my id" + " " + signedInUser.uid);
    getMyImages();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        signedInUser = user;
        print(signedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  final FirebaseAuth _aut = FirebaseAuth.instance;
  String myImage = '';
  String myName = '';

  void getMyImages() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_aut.currentUser!.uid)
        .get();
    if (userDoc == null) {
      print("feeer8aa el taswira");
    } else {
      setState(() {
        myImage = userDoc.get('userImage');
        myName = userDoc.get('name');
      });
    }
  }

  void createRoom(String senderEmail, String message, String nomReceiver,
      String imageReceiver, String idReceiver) {
    String roomName;
    if (signedInUser.uid.compareTo(idReceiver) < 0) {
      roomName = signedInUser.uid + '_' + idReceiver;
    } else {
      roomName = idReceiver + '_' + signedInUser.uid;
    }
    _firestore.collection('messages').doc(roomName).set({
      'participants': [
        myName,
        nomReceiver,
        myImage,
        imageReceiver,
        signedInUser.uid,
        idReceiver
      ],
    });
    _firestore.collection('messages').doc(roomName).collection('room').add({
      'Text': message,
      'sender': signedInUser.uid,
      'receiver': idReceiver,
      'time': FieldValue.serverTimestamp()
    });
  }

  void messagesStreams() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  String getRoomName(String senderId, String receiverId) {
    String roomName;
    if (senderId.compareTo(receiverId) < 0) {
      roomName = senderId + '_' + receiverId;
    } else {
      roomName = receiverId + '_' + senderId;
    }
    return roomName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBarForApp(
        indexNum: 5,
      ),
      backgroundColor: const Color.fromRGBO(255, 236, 239, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(55, 41, 72, 1),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                  widget.imageReceiver), // URL de l'image de l'utilisateur
              radius: 24,
            ),
            const SizedBox(width: 15),
            Text(widget.nomreceiver)
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessageStreamBuilder(
                roomName: getRoomName(
                    signedInUser.uid.toString(), widget.idReceiver)),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.orange,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        hintText: 'Write your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();

                      createRoom(
                          signedInUser.email.toString(),
                          // widget.receiverEmail,
                          messageText!,
                          widget.nomreceiver,
                          widget.imageReceiver,
                          widget.idReceiver);
                    },
                    child: Text(
                      'send',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStreamBuilder extends StatelessWidget {
  // final String receiverEmail;
  final String roomName;

  const MessageStreamBuilder({Key? key, required this.roomName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        // stream: _firestore.collection('messages').orderBy('time').snapshots(),
        stream: _firestore
            .collection('messages')
            .doc(roomName)
            .collection('room')
            .orderBy('time', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          List<MessageLine> messageWidgets = [];
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor:
                    Color.fromRGBO(55, 41, 72, 1) /* Colors.blue */,
              ),
            );
          }
          final messages = snapshot.data!.docs.reversed;

          for (var message in messages) {
            final messageText = message.get('Text');
            final messageSender = message.get('sender');
            final currentUser = signedInUser.uid;

            final messageWidget = MessageLine(
              sender: messageSender,
              text: messageText,
              isMe: currentUser == messageSender,
            );
            messageWidgets.add(messageWidget);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              children: messageWidgets,
            ),
          );
        });
  }
}

class MessageLine extends StatelessWidget {
  const MessageLine({this.text, this.sender, required this.isMe, Key? key})
      : super(key: key);
  final String? sender;
  final String? text;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Material(
              elevation: 5,
              borderRadius: isMe
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    )
                  : const BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
              color: isMe ? const Color.fromRGBO(55, 41, 72, 1) : Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
                child: Text(
                  '$text ',
                  style: TextStyle(
                      fontSize: 15, color: isMe ? Colors.white : Colors.black),
                ),
              )),
        ],
      ),
    );
  }
}
