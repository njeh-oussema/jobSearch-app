import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:frontend/Data/userData.dart';
import 'package:uuid/uuid.dart';

import '../services/global_methos.dart';

class commentData {
  Future<void> ajouterCommentaire(
      commentaire, jobId, name, userImage, BuildContext context) async {
    if (commentaire.length < 7) {
      GlobalMethode.showErrorDialog(
        error: 'la taille minimum du commmentaire est 7 caracteres',
        ctx: context,
      );
    } else {
      final _generatedId = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection('demandeTravail')
          .doc(jobId)
          .update({
        'commentaire': FieldValue.arrayUnion([
          {
            'userId': FirebaseAuth.instance.currentUser!.uid,
            'commentId': _generatedId,
            'name': name,
            'userImageUrl': userImage,
            'commentBody': commentaire,
            'time': Timestamp.now(),
          }
        ]),
      });
      await Fluttertoast.showToast(
        msg: 'votre commentaire est ajoute',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.grey,
        fontSize: 18.0,
      );
    }
  }

  Future<void> supprimerCommentaire(jobId, commentId) async {
    final jobRef =
        FirebaseFirestore.instance.collection('demandeTravail').doc(jobId);
    final jobDoc = await jobRef.get();
    final jobData = jobDoc.data();
    final comments = jobData?['commentaire'] ?? [];
    // Iterate through the comments and delete the comment with the specified commentId
    for (var i = 0; i < comments.length; i++) {
      final comment = comments[i];
      if (comment['commentId'] == commentId) {
        await jobRef.update({
          'commentaire': FieldValue.arrayRemove([comment]),
        });
        break;
      }
    }
  }

  Future<void> updateCommentaire(jobId, commentId, newComment) async {
    final jobRef =
        FirebaseFirestore.instance.collection('demandeTravail').doc(jobId);
    final jobDoc = await jobRef.get();
    final jobData = jobDoc.data();
    final comments = jobData?['commentaire'] ?? [];

    // Find the comment to edit
    for (var i = 0; i < comments.length; i++) {
      final comment = comments[i];
      if (comment['commentId'] == commentId) {
        // Modify the comment body
        comments[i]['commentBody'] = newComment;
        // Update the job document with the updated comments list
        await jobRef.update({
          'commentaire': comments,
        });
        break;
      }
    }
  }

  UserData userDatainstance = UserData();
  /*  updateComments(userId, jobId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference jobs = firestore.collection('jobs');
    DocumentSnapshot jobDocument = await jobs.doc(jobId).get();

    if (jobDocument.exists) {
      userDatainstance.getUserById(userId).then((usertable) {
        List<Object?> commentsData = List<Map<String, dynamic>>.from(
            jobDocument.get('jobComments') as List<dynamic>);
        for (var comment in commentsData) {}
      });
    }
  } */

  Future<List<Object?>> getJobComments(String jobId) async {
    // Get a reference to the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // Get a reference to the 'jobs' collection
    CollectionReference jobs = firestore.collection('demandeTravail');
    // Get the specific job document
    DocumentSnapshot jobDocument = await jobs.doc(jobId).get();
    // Check if the document exists
    if (jobDocument.exists) {
      // Extract the 'jobComments' field from the job document
      List<Object?> commentsData = List<Map<String, dynamic>>.from(
          jobDocument.get('commentaire') as List<dynamic>);
      return commentsData;
    } else {
      // Return an empty list if the document doesn't exist
      return [];
    }
  }
}
