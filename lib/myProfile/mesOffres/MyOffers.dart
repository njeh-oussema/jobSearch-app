import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Widgets/bottom_nav_bar.dart';
import 'offres_widget.dart';

class myOffers extends StatefulWidget {
  const myOffers({super.key});

  @override
  State<myOffers> createState() => _myOffersState();
}

class _myOffersState extends State<myOffers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 236, 239, 1),
      bottomNavigationBar: BottomNavigationBarForApp(indexNum: 4),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(55, 41, 72, 1),
        title: const Text("mes offres"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('offres')
            .where('id_poster',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data found!'));
          }

          final List<DocumentSnapshot> jobDocuments = snapshot.data!.docs;
          return ListView.builder(
            itemCount: jobDocuments.length,
            itemBuilder: (BuildContext context, int index) {
              final String jobId = jobDocuments[index]['job_id'];
              var _uid = FirebaseAuth.instance.currentUser!.uid;
              return Column(
                children: [
                  if (jobDocuments.isNotEmpty &&
                      _uid != jobDocuments[index]['worker_id'])
                    offer_widget(
                      status: jobDocuments[index]['status'],
                      offerId: jobDocuments[index]['offreId'],
                      jobId: jobDocuments[index]['job_id'],
                      workerId: jobDocuments[index]['worker_id'],
                      workerImage: jobDocuments[index]['worker_image'],
                      jobname: jobDocuments[index]['name_job'],
                      message: jobDocuments[index]['message'],
                      prix: jobDocuments[index]['prix'],
                      date: jobDocuments[index]['date'],
                    )
                ],
              );
            },
          );
        },
      ),
    );
  }
}
