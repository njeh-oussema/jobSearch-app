import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Data/userData.dart';
import 'package:frontend/Widgets/all_companies_widget.dart';
import 'package:frontend/Widgets/bottom_nav_bar.dart';

class AllWorkersScreen extends StatefulWidget {
  const AllWorkersScreen({super.key});

  @override
  State<AllWorkersScreen> createState() => _AllWorkersScreenState();
}

class _AllWorkersScreenState extends State<AllWorkersScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = 'Search query';
  // ignore: non_constant_identifier_names
  String? JobCategorieFilter;
  UserData userDataInstance = UserData();

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: const InputDecoration(
        hintText: 'chercher utilisateur',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    return <Widget>[
      IconButton(
        onPressed: () {
          _clearSearchQuery();
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery('');
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      print(searchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    _showTaskSecteurDialog({required Size size}) {
      Future.delayed(
        Duration.zero,
        () {
          showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  backgroundColor: Colors.black54,
                  content: Container(
                    width: size.width * 0.9,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('secteur')
                          .snapshots(),
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
                        onPressed: () {},
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

    Size size = MediaQuery.of(context).size;

    return Container(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBarForApp(
          indexNum: 1,
        ),
        backgroundColor: Color.fromRGBO(255, 236, 239, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(55, 41, 72, 1),
          automaticallyImplyLeading: false,
          title: _buildSearchField(),
          actions: _buildActions(),
          leading: IconButton(
            icon: const Icon(
              Icons.filter_list_rounded,
              color: Colors.black,
            ),
            onPressed: () {
              _showTaskSecteurDialog(size: size);
            },
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: JobCategorieFilter == null
              ? userDataInstance
                  .getUserByName(_searchQueryController.text.toLowerCase())
              : userDataInstance.getUserBySecteur(JobCategorieFilter!),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data!.docs.isNotEmpty) {
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return AllWorkersWidgets(
                        userID: snapshot.data!.docs[index]['id'],
                        userName: snapshot.data!.docs[index]['name'],
                        userEmail: snapshot.data!.docs[index]['email'],
                        phoneNumber: snapshot.data!.docs[index]['phoneNumber'],
                        userImageUrl: snapshot.data!.docs[index]['userImage'],
                      );
                    });
              } else {
                return const Center(
                  child: Text('There is no users'),
                );
              }
            }
            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            );
          },
        ),
      ),
    );
  }
}
