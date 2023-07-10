import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/Notification_screen/notification.dart';
// import 'package:frontend/Notification_screen/notification_screen.dart';
// import 'package:frontend/Search/profile_company.dart';
import 'package:frontend/Search/search_users.dart';
import 'package:frontend/demande/demande_screen.dart';
import 'package:frontend/demande/ajouter_demande.dart';
import 'package:frontend/myProfile/profilee_screeen.dart';
import 'package:frontend/user_state.dart';

import '../chatMessage/chat1.dart';

class BottomNavigationBarForApp extends StatelessWidget {
  // const BottomNavigationBar({super.key});
  int indexNum = 0;
  void _logout(context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: Row(children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.white, fontSize: 28),
                ),
              )
            ]),
            content: const Text(
              'Do you want a Log out?',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.green, fontSize: 18),
                  )),
              TextButton(
                  onPressed: () {
                    _auth.signOut();
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => UserState()));
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.green, fontSize: 18),
                  ))
            ],
          );
        });
  }

  BottomNavigationBarForApp({required this.indexNum});
  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      // color: Colors.deepOrange.shade400,
      // color: Colors.deepPurple.shade400,
      color: Color.fromRGBO(55, 41, 72, 1),

      // backgroundColor: Colors.deepPurple.shade100,
      backgroundColor: Color.fromRGBO(225, 215, 198, 1),
      // buttonBackgroundColor: Colors.deepPurple.shade300,
      buttonBackgroundColor: Color.fromRGBO(87, 155, 177, 1),

      height: 50,
      //this is a variable (ki naayto lil widget n7otolha variable index bch yaaraf win bch yemchi )
      index: indexNum,
      items: const [
        Icon(
          Icons.list,
          size: 19,
          color: Color.fromRGBO(225, 215, 198, 1),
        ),
        Icon(
          Icons.search,
          size: 19,
          color: Color.fromRGBO(225, 215, 198, 1),
        ),
        Icon(
          Icons.add,
          size: 19,
          color: Colors.white,
        ),
        Icon(
          Icons.notifications_rounded,
          size: 19,
          color: Colors.white,
        ),
        Icon(
          Icons.person_pin,
          size: 19,
          color: Colors.white,
        ),
        Icon(
          Icons.message,
          size: 19,
          color: Colors.white,
        ),
      ],
      animationDuration: Duration(milliseconds: 300),
      animationCurve: Curves.bounceInOut,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => jobScreen()));
        } else if (index == 1) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => AllWorkersScreen()));
        } else if (index == 2) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => UploadJobNow()));
        } else if (index == 3) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => notification()));
        } else if (index == 4) {
          final FirebaseAuth _auth = FirebaseAuth.instance;
          final User? user = _auth.currentUser;
          final String Uid = user!.uid;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) => /* ProfileScreen(
                userId: Uid,
              ), */
                      ProfileSceen(
                userId: Uid,
              ),
            ),
          );
          // _logout(context);
        } else if (index == 5) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder:
                      (_) => /* ProfileScreen(
                userId: Uid,
              ), */
                          // MyHomePage(),

                          // ConversationsScreen()),
                          ConversationsPage()));
          // _logout(context);
        }
      },
    );
  }
}
