import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Widgets/bottom_nav_bar.dart';
import '../demande/demande_widget.dart';

class myJob extends StatefulWidget {
  const myJob({super.key});

  @override
  State<myJob> createState() => _myJobState();
}

class _myJobState extends State<myJob> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 236, 239, 1),
      bottomNavigationBar: BottomNavigationBarForApp(indexNum: 4),
      appBar: AppBar(
        title: const Text("mes demandes"),
        backgroundColor: const Color.fromRGBO(55, 41, 72, 1),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('demandeTravail')
            .where('uploadedBy',
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
              final String jobId = jobDocuments[index]['demandeId'];
              final String jobTitle = jobDocuments[index]['titre'];
              final String jobdescription = jobDocuments[index]['description'];
              final String uploadedBy = jobDocuments[index]['uploadedBy'];
              final String myImage = jobDocuments[index]['userImage'];
              final String MyName = jobDocuments[index]['name'];
              final bool rec = jobDocuments[index]['status'];
              final String location = jobDocuments[index]['ville'];

              return Column(
                children: [
                  if (jobDocuments.isNotEmpty)
                    JobWidget(
                      jobTitle: jobTitle,
                      jobDescription: jobdescription,
                      jobId: jobId,
                      uplaodedBy: uploadedBy,
                      userImage: myImage,
                      location: location,
                      name: MyName,
                      status: rec,
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
