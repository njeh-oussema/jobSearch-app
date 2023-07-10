import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Notification_screen/notification_widget/notif_Offre.dart';
import 'package:frontend/Notification_screen/notification_widget/notification_widget.dart';
import '../Widgets/bottom_nav_bar.dart';
import 'notification_widget/notifOffreAccepted.dart';
import 'package:rxdart/rxdart.dart';

class notification extends StatefulWidget {
  const notification({super.key});

  @override
  State<notification> createState() => _notificationState();
}

class _notificationState extends State<notification> {
  Stream<QuerySnapshot> getStream1() {
    return FirebaseFirestore.instance
        .collection('demandeTravail')
        .where('uploadedBy', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  Stream<QuerySnapshot> getStream2(String currentUserId) {
    return FirebaseFirestore.instance
        .collection('offres')
        .where('id_poster', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'waiting')
        .snapshots();
  }

  Stream<QuerySnapshot> getStream3(String currentUserId) {
    return FirebaseFirestore.instance
        .collection('offres')
        .where('worker_id', isEqualTo: currentUserId)
        // .where('worker_id' != 'id_poster')
        .where('status', isEqualTo: 'accepted')
        .snapshots();
  }

  Stream<List<QuerySnapshot>> getCombinedStream(String currentUserId) {
    return Rx.combineLatest3(
      getStream1(),
      getStream2(currentUserId),
      getStream3(currentUserId),
      (QuerySnapshot a, QuerySnapshot b, QuerySnapshot c) => [a, b, c],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 236, 239, 1),
      bottomNavigationBar: BottomNavigationBarForApp(indexNum: 3),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(55, 41, 72, 1),
        title: const Text("notification"),
      ),
      body: StreamBuilder<List<QuerySnapshot>>(
        stream: getCombinedStream(currentUserId),
        builder: (BuildContext context,
            AsyncSnapshot<List<QuerySnapshot>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final jobDocuments = snapshot.data![0].docs;
          final offreDocuments1 = snapshot.data![1].docs;
          final offreDocuments2 = snapshot.data![2].docs;
          List<Widget> notifications = [];
          if (jobDocuments.isNotEmpty) {
            for (var jobDoc in jobDocuments) {
              final comments = jobDoc['commentaire'];
              for (var comment in comments) {
                if (comment['userId'] != currentUserId) {
                  notifications.add(Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: notifWidget(
                      message: "new comment",
                      commentBody: comment['commentBody'],
                      name: comment['name'],
                      userImageUrl: comment['userImageUrl'],
                      jobId: jobDoc['demandeId'],
                      uploadedBy: currentUserId,
                      jobname: jobDoc['titre'],
                      id: comment['userId'],
                    ),
                  ));
                }
              }
            }
          }

          if (offreDocuments1.isNotEmpty) {
            for (int j = 0; j < offreDocuments1.length; j++) {
              if (offreDocuments1[j]['id_poster'] !=
                  offreDocuments1[j]['worker_id']) {
                notifications.add(Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: notif_offre(
                    name: offreDocuments1[j]['worker_name'],
                    userImageUrl: offreDocuments1[j]['worker_image'],
                    commentBody: offreDocuments1[j]['message'],
                    jobId: offreDocuments1[j]['job_id'],
                    uploadedBy: currentUserId,
                    jobname: offreDocuments1[j]['name_job'],
                    id: offreDocuments1[j]['id_poster'],
                  ),
                ));
              }
            }
          }
          if (offreDocuments2.isNotEmpty) {
            for (int s = 0; s < offreDocuments2.length; s++) {
              notifications.add(
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: notif_offre_accepted(
                    name: offreDocuments2[s]['name_poster'],
                    userImageUrl: offreDocuments2[s]['worker_image'],
                    commentBody: offreDocuments2[s]['message'],
                    poseterimage: offreDocuments2[s]['image_poster'],
                    jobId: offreDocuments2[s]['job_id'],
                    uploadedBy: offreDocuments2[s]['id_poster'],
                    jobname: offreDocuments2[s]['name_job'],
                    id: offreDocuments2[s]['id_poster'],
                  ),
                ),
              );
            }
          }
          return ListView(
            children: notifications,
          );
        },
      ),
    );
  }
}
