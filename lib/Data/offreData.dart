import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/global_methos.dart';
import 'package:uuid/uuid.dart';

class offreData {
  Future<int> getNumberOffer(idWorker, idJob) async {
    final QuerySnapshot<Map<String, dynamic>> offerDoc = await FirebaseFirestore
        .instance
        .collection('offres')
        .where('worker_id', isEqualTo: idWorker)
        .where('job_id', isEqualTo: idJob)
        .get();
    int nbr = offerDoc.docs.length;
    return nbr;
  }

  Future<void> ajouterOffre(jobId, nameWorker, userImage, jobTitle, idClient,
      nomClient, imageClient, message, prix, date, BuildContext context) async {
    final offreId = const Uuid().v4();
    int maxoffer = 3;
    String curr = FirebaseAuth.instance.currentUser!.uid;

    int numberOfOffers = await getNumberOffer(curr, jobId);

    if (numberOfOffers >= maxoffer) {
      GlobalMethode.showErrorDialog(
          error:
              "vous n’avez pas le droit d envoyer plus que  $maxoffer offres dans la même demande",
          ctx: context);
    } else {
      try {
        await FirebaseFirestore.instance.collection('offres').doc(offreId).set({
          'offreId': offreId,
          'job_id': jobId,
          'name_job': jobTitle,
          'worker_id': curr,
          'worker_name': nameWorker,
          'worker_image': userImage,
          'id_poster': idClient,
          'name_poster': nomClient,
          'image_poster': imageClient,
          'message': message,
          'status': 'waiting',
          'prix': prix,
          'date': date,
        });
      } catch (err) {
        GlobalMethode.showErrorDialog(error: err.toString(), ctx: context);
      }
    }
  }
}
