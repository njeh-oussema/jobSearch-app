import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/Data/commentData.dart';
import 'package:frontend/myProfile/profilee_screeen.dart';
import '../../services/global_methos.dart';

class CommentWidget extends StatefulWidget {
  final String jobId;
  final String uplaodedBy;
  final String commentId;
  final String commenterId;
  final String commenterName;
  final String commentBody;
  final String commenterImageUrl;
  const CommentWidget({
    required this.uplaodedBy,
    required this.jobId,
    required this.commentId,
    required this.commenterId,
    required this.commenterName,
    required this.commentBody,
    required this.commenterImageUrl,
  });
  // const CommentWidget({super.key});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  TextEditingController Comment_Controller = TextEditingController();

  final List<Color> _colors = [
    Colors.amber,
    Colors.orange,
    Colors.pink.shade200,
    Colors.brown,
    Colors.cyan,
    Colors.blueAccent,
    Colors.deepOrange
  ];
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  bool _isSameUser = false;
  commentData commentDataInstance = commentData();
  deleteCommentFromJob(String jobId, String commentId) async {}
  _editComment() {
    String _text = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Titre'),
          content: TextField(
            controller: Comment_Controller,
            decoration: const InputDecoration(
              hintText: 'Entrez votre texte ici',
            ),
          ),
          actions: [
            MaterialButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            MaterialButton(
              child: const Text('Valider'),
              onPressed: () {
                commentDataInstance.updateCommentaire(
                    widget.jobId, widget.commentId, Comment_Controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _choiceComment() {
    User? user = _auth.currentUser;
    final _uid = user!.uid;
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    if (widget.commenterId == _uid) {
                      commentDataInstance.supprimerCommentaire(
                          widget.jobId, widget.commentId);
                      await Fluttertoast.showToast(
                          msg: 'commentaire supprimé',
                          toastLength: Toast.LENGTH_LONG,
                          backgroundColor: Colors.grey,
                          fontSize: 18.0);

                      Navigator.canPop(context) ? Navigator.pop(context) : null;
                    } else {
                      GlobalMethode.showErrorDialog(
                          error: 'You cannot perform this action', ctx: ctx);
                    }
                  } catch (error) {
                    GlobalMethode.showErrorDialog(
                        error: 'This task cannot be deletaed', ctx: ctx);
                  } finally {}
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    Text(
                      'supprimer',
                      style: TextStyle(color: Colors.red),
                    )
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final jobRef = FirebaseFirestore.instance
                        .collection('demandeTravail')
                        .doc(widget.jobId);
                    final jobDoc = await jobRef.get();
                    final jobData = jobDoc.data();
                    final comments = jobData?['commentaire'] ?? [];
                    for (var i = 0; i < comments.length; i++) {
                      final comment = comments[i];
                      if (comment['commentId'] == widget.commentId) {
                        Comment_Controller.text = comments[i]['commentBody'];
                      }
                    }
                    await _editComment();
                  } catch (error) {
                    GlobalMethode.showErrorDialog(
                        error: 'This task cannot be deletaed', ctx: ctx);
                  } finally {}
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.edit,
                      color: Color.fromRGBO(55, 41, 72, 1),
                    ),
                    Text(
                      'modifier',
                      style: TextStyle(color: Color.fromRGBO(55, 41, 72, 1)),
                    )
                  ],
                ),
              ),
            ],
          );
        });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    // TODO: implement initState
    User? user = _auth.currentUser;
    final _uid = user!.uid;
    setState(() {
      _isSameUser = _uid == widget.commenterId;
    });
  }

  @override
  Widget build(BuildContext context) {
    _colors.shuffle();
    return InkWell(
      onLongPress: () {
        _isSameUser == true ? _choiceComment() : "";
      },
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileSceen(userId: widget.commenterId),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
              flex: 1,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: _colors[1],
                    ),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(widget.commenterImageUrl),
                      fit: BoxFit.fill,
                    )),
              )),
          const SizedBox(
            width: 6,
          ),
          Flexible(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.commenterName,
                  style: const TextStyle(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 16),
                ),
                Text(
                  widget.commentBody,
                  style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                      fontSize: 16),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
