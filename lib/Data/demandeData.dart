import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

// ignore: camel_case_types
class jobData {
  void ajoutrerDemande(
      TextEditingController _jobTitleController,
      _jobCategorieController,
      _JobDescripController,
      _JobDeadLineController,
      deadLineDateTimeStamp,
      name,
      userImage,
      location,
      List<String> imageUrls) async {
    final demandeId = const Uuid().v4();
    User? user = FirebaseAuth.instance.currentUser;
    final _uid = user!.uid;

    try {
      await FirebaseFirestore.instance
          .collection('demandeTravail')
          .doc(demandeId)
          .set({
        'demandeId': demandeId,
        'uploadedBy': _uid,
        'email': user.email,
        'titre': _jobTitleController.text,
        'description': _JobDescripController.text,
        'deadLineDate': _JobDeadLineController.text,
        'deadLineDateTimeStamp': deadLineDateTimeStamp,
        'secteur': _jobCategorieController.text,
        'commentaire': [],
        'status': true,
        'createdAt': Timestamp.now(),
        'name': name,
        'userImage': userImage,
        'ville': location,
        'applicants': 0,
        'imageUrls': imageUrls,
      });
      await Fluttertoast.showToast(
        msg: 'la demande est ajouté',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.grey,
        fontSize: 18.0,
      );
      _jobTitleController.clear();
      _JobDescripController.clear();
    } catch (error) {
    } finally {}
  }

  Future<void> updateoffreDeDemande(jobId, newName) async {
    QuerySnapshot offerDocs = await FirebaseFirestore.instance
        .collection('offres')
        .where('job_id', isEqualTo: jobId)
        .get();

    for (QueryDocumentSnapshot offerDoc in offerDocs.docs) {
      await offerDoc.reference.update({'name_job': newName});
    }
  }

  Future<void> updateDemande(
      jobId, title, category, description, deadline, imageUrls) async {
    await FirebaseFirestore.instance
        .collection('demandeTravail')
        .doc(jobId)
        .update({
      'titre': title,
      'secteur': category,
      'description': description,
      'deadLineDate': deadline,
      "imageUrls": imageUrls
    });
    await updateoffreDeDemande(jobId, title);
    await Fluttertoast.showToast(
      msg: 'la demande est modifié',
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.grey,
      fontSize: 18.0,
    );
  }

  Future<void> supprimerDemande(jobId) async {
    DocumentSnapshot jobDoc = await FirebaseFirestore.instance
        .collection('demandeTravail')
        .doc(jobId)
        .get();

    if (jobDoc.exists) {
      List<String> imageUrls = List<String>.from(jobDoc.get('imageUrls'));
      FirebaseStorage storage = FirebaseStorage.instance;

      for (String imageUrl in imageUrls) {
        Reference ref = storage.refFromURL(imageUrl);
        await ref.delete();
      }
      QuerySnapshot offerDocs = await FirebaseFirestore.instance
          .collection('offres')
          .where('job_id', isEqualTo: jobId)
          .get();

      for (QueryDocumentSnapshot offerDoc in offerDocs.docs) {
        await offerDoc.reference.delete();
      }
      await FirebaseFirestore.instance
          .collection('demandeTravail')
          .doc(jobId)
          .delete();
      await Fluttertoast.showToast(
          msg: 'la demande et les offres associées ont été supprimées',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0);
    }
  }

  Stream<QuerySnapshot> getFiltred(String jobCategoryFilter) {
    var collection = FirebaseFirestore.instance
        .collection('demandeTravail')
        .where('status', isEqualTo: true)
        .orderBy('createdAt', descending: false);

    if (jobCategoryFilter != null) {
      collection = collection.where('secteur', isEqualTo: jobCategoryFilter);
    }
    return collection.snapshots();
  }

  Stream<QuerySnapshot> getAll() {
    var collection = FirebaseFirestore.instance
        .collection('demandeTravail')
        .where('status', isEqualTo: true)
        .orderBy('createdAt', descending: false);

    return collection.snapshots();
  }

  Future<Map<String, dynamic>> getDemandeByid(jobId) async {
    Map<String, dynamic> jobData1 = {};

    final DocumentSnapshot jobDatabase = await FirebaseFirestore.instance
        .collection('demandeTravail')
        .doc(jobId)
        .get();

    if (jobDatabase == null) {
      return jobData1;
    }

    jobData1 = {
      'titre': jobDatabase.get('titre'),
      'description': jobDatabase.get('description'),
      'status': jobDatabase.get('status'),
      'ville': jobDatabase.get('ville'),
      'applicants': jobDatabase.get('applicants'),
      'postedDateTimeStamp': jobDatabase.get('createdAt'),
      'deadlineDateTimeStamp': jobDatabase.get('deadLineDateTimeStamp'),
      'deadlineDate': jobDatabase.get('deadLineDate'),
      'emailCompany': jobDatabase.get('email'),
      'authorName': jobDatabase.get('name'),
      'userImageUrl': jobDatabase.get('userImage'),
      'userId': jobDatabase.get('uploadedBy'),
      'imageUrls': List<String>.from(jobDatabase.get('imageUrls') ?? []),
    };

    var postDate = jobData1['postedDateTimeStamp']!.toDate();
    jobData1['postedDate'] =
        '${postDate.year}-${postDate.month}-${postDate.day}';

    var date = jobData1['deadlineDateTimeStamp']!.toDate();
    jobData1['isDeadlineAvailable'] = date.isAfter(DateTime.now());

    return jobData1;
  }

  void updateStatus(bool status, jobId) {
    FirebaseFirestore.instance
        .collection('demandeTravail')
        .doc(jobId)
        .update({'status': status});
  }

  Future<int> getOfferCount(String jobId) async {
    int count = 0;
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('offre')
          .where('job_id', isEqualTo: jobId)
          .get();

      count = snapshot.size;
    } catch (error) {
      print('Error retrieving offer count: $error');
    }
    return count;
  }
}
