import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/myProfile/chat.dart';
import 'package:intl/intl.dart';

class messageData {
  void createRoom(String senderEmail, String receiverEmail, String message,
      String nomReceiver, String imageReceiver) {
    String roomName;
    if (senderEmail.compareTo(receiverEmail) < 0) {
      roomName = senderEmail + '_' + receiverEmail;
    } else {
      roomName = receiverEmail + '_' + senderEmail;
    }

    FirebaseFirestore.instance.collection('messages').doc(roomName).set({
      'participants': [
        senderEmail,
        receiverEmail,
        nomReceiver,
        imageReceiver,
        signedInUser.uid.toString()
      ],
    });
    FirebaseFirestore.instance
        .collection('messages')
        .doc(roomName)
        .collection('room')
        .add({
      'Text': message,
      'sender': senderEmail,
      'receiver': receiverEmail,
      'time': FieldValue.serverTimestamp()
    });
  }

  String getRoomName(String senderEmail, String receiverEmail) {
    String roomName;
    if (senderEmail.compareTo(receiverEmail) < 0) {
      roomName = senderEmail + '_' + receiverEmail;
    } else {
      roomName = receiverEmail + '_' + senderEmail;
    }
    return roomName;
  }

  Future<String> getLastMessage(String roomId) async {
    QuerySnapshot messages = await FirebaseFirestore.instance
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

    return '';
  }
}
