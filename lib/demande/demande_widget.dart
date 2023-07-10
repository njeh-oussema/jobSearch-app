import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/demande/edit_demande.dart';
import 'package:frontend/Data/demandeData.dart';
import 'package:frontend/demande/Detail_demande/demande_Detail.dart';
import 'package:frontend/services/global_methos.dart';

class JobWidget extends StatefulWidget {
  final String jobTitle;
  final String jobDescription;
  final String jobId;
  final String uplaodedBy;
  final String userImage;
  final String name;
  final bool status;
  final String location;

  const JobWidget({
    super.key,
    required this.jobTitle,
    required this.jobDescription,
    required this.jobId,
    required this.uplaodedBy,
    required this.userImage,
    required this.name,
    required this.status,
    required this.location,
  });

  @override
  State<JobWidget> createState() => _JobWidgetState();
}

class _JobWidgetState extends State<JobWidget> {
  bool _isSameUser = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  _deleteDialog() {
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
                      if (widget.uplaodedBy == _uid) {
                        jobData jobDataInstance = jobData();
                        jobDataInstance.supprimerDemande(widget.jobId);
                        Navigator.pop(ctx);
                      } else {
                        GlobalMethode.showErrorDialog(
                            error: 'You cannot perform this action', ctx: ctx);
                      }
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
                  )),
              TextButton(
                onPressed: () async {
                  try {
                    if (widget.uplaodedBy == _uid) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (c) => EditJob(
                                    jobId: widget.jobId,
                                  )));
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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(184, 149, 149, 1),
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
        onTap: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailScreen(
                  userId: widget.uplaodedBy,
                  uploadedBy: widget.uplaodedBy,
                  jobId: widget.jobId,
                ),
              ));
        },
        onLongPress: () {
          User? user = _auth.currentUser;
          final _uid = user!.uid;
          if (_uid == widget.uplaodedBy) {
            _deleteDialog();
          }
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.only(right: 12),
          decoration:
              const BoxDecoration(border: Border(right: BorderSide(width: 1))),
          child: Image.network(widget.userImage),
        ),
        title: Text(widget.jobTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color.fromRGBO(37, 27, 55, 1),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(widget.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color.fromRGBO(37, 41, 72, 1),
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                )),
            const SizedBox(
              height: 8,
            ),
            Text(
              widget.jobDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w200,
                  fontSize: 13),
            )
          ],
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_right,
          size: 30,
          color: Color.fromRGBO(37, 27, 55, 1),
        ),
      ),
    );
  }
}
