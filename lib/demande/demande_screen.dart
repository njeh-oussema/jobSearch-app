import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Data/secteurData.dart';
import 'package:frontend/Search/search_demande.dart';
import 'package:frontend/demande/demande_widget.dart';
import '../Widgets/bottom_nav_bar.dart';
import '../Data/demandeData.dart';

class jobScreen extends StatefulWidget {
  const jobScreen({super.key});

  @override
  State<jobScreen> createState() => _jobScreenState();
}

class _jobScreenState extends State<jobScreen> {
  String? JobCategorieFilter;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  secteurData secteurInstance = secteurData();

  jobData jobDataInstance = jobData();

  _showTaskSecteurDialog({required Size size}) {
    Future.delayed(
      Duration.zero,
      () {
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                backgroundColor: Colors.black54,
                content: SizedBox(
                  width: size.width * 0.9,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: secteurInstance.getSecteur(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final docs = snapshot.data!.docs;
                      return ListView.builder(
                        itemBuilder: (ctx, index) {
                          final doc = docs[index];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                JobCategorieFilter = doc['name'];
                              });
                              Navigator.pop(context);
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.work,
                                  color: Colors.grey,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    doc['name'],
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 16),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                        shrinkWrap: true,
                        itemCount: docs.length,
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          JobCategorieFilter = null;
                        });
                        Navigator.canPop(context)
                            ? Navigator.pop(context)
                            : null;
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )),
                  TextButton(
                      onPressed: () {
                        // _addsecteur();
                      },
                      child: const Text(
                        "add",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )),
                ],
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 0),
        backgroundColor: const Color.fromRGBO(255, 236, 239, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(55, 41, 72, 1),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.filter_list_rounded,
              color: Colors.black,
            ),
            onPressed: () {
              _showTaskSecteurDialog(size: size);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (c) => const SearchScreen()));
              },
            )
          ],
        ),
        //we show all the job that their recruitments will be True
        body: StreamBuilder<QuerySnapshot>(
            stream: JobCategorieFilter == null
                ? jobDataInstance.getAll()
                : jobDataInstance.getFiltred(JobCategorieFilter!),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.data?.docs.isNotEmpty == true) {
                  return ListView.builder(
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return JobWidget(
                          jobTitle: snapshot.data?.docs[index]['titre'],
                          jobDescription: snapshot.data?.docs[index]
                              ['description'],
                          jobId: snapshot.data?.docs[index]['demandeId'],
                          uplaodedBy: snapshot.data?.docs[index]['uploadedBy'],
                          userImage: snapshot.data?.docs[index]['userImage'],
                          name: snapshot.data?.docs[index]['name'],
                          status: snapshot.data?.docs[index]['status'],
                          // email: snapshot.data?.docs[index]['email'],
                          location: snapshot.data?.docs[index]['ville'],
                        );
                      });
                } else {
                  return const Center(
                    child: Text('There is no jobs'),
                  );
                }
              }

              return const Center(
                child: Text(
                  'Something went wrong',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              );
            }));
  }
}
