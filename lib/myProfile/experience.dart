import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Widgets/bottom_nav_bar.dart';
import '../demande/demande_widget.dart';

class ExperiencePage extends StatefulWidget {
  final String userId;

  ExperiencePage({required this.userId});

  @override
  _ExperiencePageState createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<ExperiencePage> {
  late Future<List<String>> acceptedJobIds;
  @override
  void initState() {
    super.initState();
    acceptedJobIds = fetchAcceptedJobIds();
  }

  Future<List<String>> fetchAcceptedJobIds() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('offres')
        .where('worker_id', isEqualTo: widget.userId)
        .where('status', isEqualTo: 'accepted')
        .get();

    final List<dynamic> jobIds =
        snapshot.docs.map((doc) => doc['job_id']).toList();
    final List<String> jobIdsString = jobIds.cast<String>();
    return jobIdsString;
  }

// print(jobI)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBarForApp(
        indexNum: 4,
      ),
      backgroundColor: const Color.fromRGBO(255, 236, 239, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(55, 41, 72, 1),
        title: const Text('Expérience'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: () async* {
          final List<String> jobIds = await acceptedJobIds;
          if (jobIds.isEmpty) {
            const Text("no experience");
          } else {
            yield* FirebaseFirestore.instance
                .collection('demandeTravail')
                .where('demandeId', whereIn: jobIds)
                .snapshots();
          }
        }(),
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
              // ignore: non_constant_identifier_names
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
                      // email: email,
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
