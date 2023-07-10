import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/chatMessage/Widget.dart';
import 'package:frontend/myProfile/chat.dart';
import '../Widgets/bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class RoomTile extends StatelessWidget {
  final String roomId;
  final String otherParticipant;

  RoomTile({required this.roomId, required this.otherParticipant});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(otherParticipant),
      onTap: () {},
    );
  }
}

class ConversationsPage extends StatefulWidget {
  static const String screenRoute = 'conversations_page';

  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  final _firestore = FirebaseFirestore.instance;
  late User signedInUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getMyImages();
  }

  String myImage = '';
  String myName = '';

  final FirebaseAuth _aut = FirebaseAuth.instance;

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

  void getCurrentUser() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        signedInUser = user;
        print(signedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> getUserName(String email) async {
    DocumentSnapshot userDocument =
        await _firestore.collection('users').doc(email).get();
    return userDocument.get('name');
  }

  Future<String> getLastMessageTime(String roomId) async {
    QuerySnapshot messages = await FirebaseFirestore.instance
        .collection('messages')
        .doc(roomId)
        .collection('room')
        .orderBy('time', descending: true)
        .limit(1)
        .get();

    if (messages.docs.isNotEmpty) {
      var timestamp = messages.docs.first.get('time');
      if (timestamp != null) {
        DateTime dateTime = timestamp.toDate();
        String timeString = DateFormat('HH:mm').format(dateTime);
        return timeString;
      }
    }

    return ''; // Returns an empty string if no message is found
  }

  Future<String> getLastMessage(String roomId) async {
    QuerySnapshot messages = await _firestore
        .collection('messages')
        .doc(roomId)
        .collection('room')
        .orderBy('time', descending: true)
        .limit(1)
        .get();

    if (messages.docs.isNotEmpty) {
      return messages.docs.first.get('Text');
    }

    return '';
    // Retourne une chaîne vide si aucun message n'est trouvé
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 200, 239, 1),
      bottomNavigationBar: BottomNavigationBarForApp(
        indexNum: 5,
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(55, 41, 72, 1),
        title: const Text('Conversations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('messages').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          // Filtrer la liste des rooms où l'utilisateur actuel est un participant
          final rooms = snapshot.data!.docs
              .where((room) => room['participants'].contains(signedInUser.uid))
              .toList();
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              String otherParticipant = room['participants']
                  .firstWhere((participant) => participant != signedInUser.uid);
              print(rooms.length);

              return FutureBuilder<String>(
                future: getLastMessage(room.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    // Une erreur s'est produite, affichez un message d'erreur
                    return Text('Erreur: ${snapshot.error}');
                  }

                  String lastMessage =
                      snapshot.data ?? ''; // Obtenez le dernier message

                  return ChatWidgets.card(
                    titleRoom: myName == room['participants'][0]
                        ? room['participants'][1]
                        : room['participants'][0],
                    subtitleText: lastMessage,
                    time: getLastMessageTime(room.id),
                    imageUrl: myImage == room['participants'][2]
                        ? room['participants'][3]
                        : room['participants'][2],
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return ChatScreen(
                              nomreceiver: myName == room['participants'][0]
                                  ? room['participants'][1]
                                  : room['participants'][0],
                              imageReceiver: myImage == room['participants'][2]
                                  ? room['participants'][3]
                                  : room['participants'][2],
                              idReceiver:
                                  signedInUser.uid == room['participants'][4]
                                      ? room['participants'][5]
                                      : room['participants'][4],
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
