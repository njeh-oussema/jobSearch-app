import 'package:flutter/material.dart';
import '../../myProfile/mesOffres/MyOffers.dart';

class notif_offre extends StatefulWidget {
  final String name;
  final String userImageUrl;
  final String commentBody;
  final String jobId;
  final String uploadedBy;
  final String jobname;
  final String id;

  const notif_offre({
    required this.name,
    required this.userImageUrl,
    required this.commentBody,
    required this.jobId,
    required this.uploadedBy,
    required this.jobname,
    required this.id,
  });

  @override
  State<notif_offre> createState() => _notif_offreState();
}

class _notif_offreState extends State<notif_offre> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => myOffers()), // Replace with your page
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: widget.userImageUrl != null
                  ? NetworkImage(widget.userImageUrl)
                  : const NetworkImage(
                      "https://media.istockphoto.com/id/1209654046/vector/user-avatar-profile-icon-black-vector-illustration.jpg?s=612x612&w=0&k=20&c=EOYXACjtZmZQ5IsZ0UUp1iNmZ9q2xl1BD1VvN6tZ2UI="),
            ),
            const SizedBox(
              width: 15,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(color: Color.fromRGBO(55, 41, 72, 1)),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  "New offer for you",
                  style: TextStyle(color: Colors.black, fontSize: 12),
                )
              ],
            ),
          ],
        ));
  }
}
