import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/demande/Detail_demande/demande_Detail.dart';
import '../../myProfile/profilee_screeen.dart';

class notifWidget extends StatefulWidget {
  // const JobWidget({super.key});
  final String message;
  final String name;
  final String userImageUrl;
  final String commentBody;
  // final Timestamp time;
  final String jobId;
  final String uploadedBy;
  final String jobname;
  final String id;

  const notifWidget({
    required this.message,
    required this.name,
    required this.userImageUrl,
    required this.commentBody,
    // required this.time,
    required this.jobId,
    required this.uploadedBy,
    required this.jobname,
    required this.id,
  });

  @override
  State<notifWidget> createState() => _notifWidgetState();
}

class _notifWidgetState extends State<notifWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white24,
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
        onTap: () {
          // _deleteDialog();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailScreen(
                  userId: widget.uploadedBy,
                  uploadedBy: widget.uploadedBy,
                  jobId: widget.jobId,
                ),
              ));
        },
        onLongPress: () {},
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileSceen(userId: widget.id),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.only(right: 12),
              decoration: const BoxDecoration(
                  border: Border(right: BorderSide(width: 1))),
              child: Image.network(widget.userImageUrl),
            )),
        title: Text(widget.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.pink,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("${widget.message + "  " + "on"} ${widget.jobname}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  )),
              const SizedBox(
                height: 8,
              ),
              Text(
                "${widget.commentBody}",
                style: const TextStyle(color: Colors.redAccent),
              )
            ]),
        trailing: const Icon(
          Icons.keyboard_arrow_right,
          size: 30,
          color: Colors.black,
        ),
      ),
    );
  }
}
