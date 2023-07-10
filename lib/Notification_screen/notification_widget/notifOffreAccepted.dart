import 'package:flutter/material.dart';

class notif_offre_accepted extends StatefulWidget {
  final String poseterimage;
  final String name;
  final String userImageUrl;
  final String commentBody;
  final String jobId;
  final String uploadedBy;
  final String jobname;
  final String id;
  notif_offre_accepted({
    required this.poseterimage,
    required this.name,
    required this.userImageUrl,
    required this.commentBody,
    required this.jobId,
    required this.uploadedBy,
    required this.jobname,
    required this.id,
  });

  @override
  State<notif_offre_accepted> createState() => _notif_offre_acceptedState();
}

class _notif_offre_acceptedState extends State<notif_offre_accepted> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: CircleAvatar(
                radius: 25,
                backgroundImage: widget.userImageUrl != null
                    ? NetworkImage(widget.userImageUrl)
                    : const NetworkImage(
                        "https://media.istockphoto.com/id/1209654046/vector/user-avatar-profile-icon-black-vector-illustration.jpg?s=612x612&w=0&k=20&c=EOYXACjtZmZQ5IsZ0UUp1iNmZ9q2xl1BD1VvN6tZ2UI="),
              ),
            ),
            Positioned(
                bottom: 10,
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: widget.userImageUrl != null
                      ? NetworkImage(widget.poseterimage)
                      : const NetworkImage(
                          "https://media.istockphoto.com/id/1209654046/vector/user-avatar-profile-icon-black-vector-illustration.jpg?s=612x612&w=0&k=20&c=EOYXACjtZmZQ5IsZ0UUp1iNmZ9q2xl1BD1VvN6tZ2UI="),
                ))
          ]),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                maxLines: 2,
                text: TextSpan(
                  text: "  ${widget.name} \n",
                  style: const TextStyle(color: Colors.black),
                  children: const [
                    TextSpan(text: " accept your offre"),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                widget.jobname,
                style: const TextStyle(color: Colors.green),
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Image.network(
            widget.userImageUrl,
            height: 60,
            width: 64,
          ),
        )
      ],
    );
  }
}
