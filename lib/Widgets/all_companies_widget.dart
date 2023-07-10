import 'package:flutter/material.dart';
import 'package:frontend/myProfile/profilee_screeen.dart';

class AllWorkersWidgets extends StatefulWidget {
  String userID;
  String userName;
  String userEmail;
  String phoneNumber;
  String userImageUrl;

  AllWorkersWidgets(
      {required this.userID,
      required this.userEmail,
      required this.phoneNumber,
      required this.userName,
      required this.userImageUrl});
  @override
  State<AllWorkersWidgets> createState() => _AllWorkersWidgetsState();
}

class _AllWorkersWidgetsState extends State<AllWorkersWidgets> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: const Color(0xFF5C4760),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileSceen(userId: widget.userID)));
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        leading: Container(
          padding: const EdgeInsets.only(right: 12),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(width: 1),
            ),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 20,
            child: Image.network(widget.userImageUrl == null
                ? 'https://static.vecteezy.com/system/resources/previews/000/439/863/original/vector-users-icon.jpg'
                : widget.userImageUrl),
          ),
        ),
        title: Text(
          widget.userName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Text(
                'Visit Profile',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey,
                ),
              )
            ]),
      ),
    );
  }
}
