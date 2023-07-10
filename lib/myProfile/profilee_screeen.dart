import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frontend/Data/userData.dart';
import 'package:frontend/Widgets/bottom_nav_bar.dart';
import 'package:frontend/myProfile/chat.dart';
import 'package:frontend/myProfile/MesDemandes.dart';
import 'package:frontend/myProfile/profile_menu.dart';
import 'package:frontend/myProfile/update_profile.dart';
import 'package:frontend/services/global_methos.dart';
import 'package:frontend/user_state.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'experience.dart';
import 'mesOffres/MyOffers.dart';

class ProfileSceen extends StatefulWidget {
  final String userId;
  const ProfileSceen({required this.userId});
  @override
  State<ProfileSceen> createState() => _ProfileSceenState();
}

const tDashboardHeading = "Explore Course";
const tDashboardSearch = "search...";
const tDashboardBannerTitle2 = "JAVA";
const tDashboardButton = "View All";
const tDashboardTopCourses = "Top courses";
const tDashboardBannerSubTitle = "10 lessons";
const tDashboardBannerSubTitle1 = "oussema.njeh123@gmail.com";

//profile screen  text
const String tProfile = "Profile";
const String tEditProfile = "Edit Profile";
const String tLogoutDialogHeading = "Logout";
const String tProfileHeading = "Coding with T";
const String tProfileSubHeading = "oussema.njeh123@gmail.com";
//menu
Color tAccentColor = Colors.blue;
const String tMenu1 = "Settings";
const String tMenu2 = "Billing Details";
const String tMenu3 = "User Management";
const String tMenu4 = "Information";
const String tMenu5 = "LOG out";
// Update Profile Screen text
const String tDelete = "Delete";
const String tJoined = "Joined";
const String tJoinedAt = "31 October 2022";
final FirebaseAuth _auth = FirebaseAuth.instance;
const IconData local_offer = IconData(
  0xe8a3,
  fontFamily: 'MaterialIcons',
  fontPackage: 'flutter',
);

//colors
Color tdarkColor = Colors.black;
Color tPrimaryColor = Colors.amber;

void _logout(context) {
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
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => UserState()));
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Colors.green, fontSize: 18),
                ))
          ],
        );
      });
}

class _ProfileSceenState extends State<ProfileSceen> {
  final FirebaseAuth _aut = FirebaseAuth.instance;
  String myImage = '';

  String? name = '';
  String email = '';
  String phoneNumber = '';
  String imageUrl = '';
  String secteur = '';

  String joinedAt = '';
  bool _isLoading = false;
  bool _isSameUser = false;
  double averageRating = 0;
  double rate = 0.0;
  @override
  void initState() {
    super.initState();
    getuserdata1();
    _calculateAverageRating();
    getMyImages();
  }

  void _calculateAverageRating() async {
    final CollectionReference userRef =
        FirebaseFirestore.instance.collection('users');
    final docSnapshot = await userRef.doc(widget.userId).get();

    if (docSnapshot.exists) {
      final ratings = List<Map<String, dynamic>>.from(
          docSnapshot.get('ratings') as List<dynamic>);

      if (ratings.isNotEmpty) {
        double totalRating = 0.0;
        for (final rating in ratings) {
          totalRating += rating['rating'] as double;
        }
        final averageRating = totalRating / ratings.length;

        await userRef.doc(widget.userId).update({'note': averageRating});

        setState(() {
          this.averageRating = averageRating;
          rate = averageRating;
        });
      } else {
        setState(() {
          this.averageRating = 0.0;
        });
      }
    } else {}
  }

  Widget _contactBy(
      {required Color color, required Function fct, required IconData icon}) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: CircleAvatar(
        radius: 23,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(
            icon,
            color: color,
          ),
          onPressed: () {
            fct();
          },
        ),
      ),
    );
  }

  void _openWatsappChat() async {
    var url = 'https://wa.me/$phoneNumber?text=Helloworld';
    launchUrlString(url);
  }

  void _mailTo() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=Write subject here, Please&body=Hello, please write details here',
    );
    final url = params.toString();
    launchUrlString(url);
  }

  void _callPhoneNumber() async {
    var url = 'tel://$phoneNumber';
    launchUrlString(url);
  }

  void rateuser(double note) async {
    userDataInstance.rateuser(note, widget.userId);
  }

  UserData userDataInstance = UserData();
  void getuserdata1() async {
    try {
      userDataInstance.getUserById(widget.userId).then((usertable) {
        setState(() {
          name = usertable['name'];
          email = usertable['email'];
          phoneNumber = usertable['phoneNumber'];
          imageUrl = usertable['imageUrl'];
          secteur = usertable['secteur'];
          Timestamp joinedAtTimeStamp = usertable['joinedAtTimeStamp'];
          var joinedDate = joinedAtTimeStamp.toDate();
          joinedAt = '${joinedDate.year}-${joinedDate.month}-${joinedDate.day}';
        });
      });
      User? user = _auth.currentUser;
      final _uid = user!.uid;

      setState(() {
        _isSameUser = _uid == widget.userId;
      });
    } catch (e) {
      GlobalMethode.showErrorDialog(error: e.toString(), ctx: context);
    }
  }

  void getMyImages() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_aut.currentUser!.uid)
        .get();
    if (userDoc == null) {
      // return;
      print("feeer8aa el taswira");
    } else {
      setState(() {
        myImage = userDoc.get('userImage');
      });
    }
  }

  void getUserData() async {
    try {
      _isLoading = true;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      // ignore: unnecessary_null_comparison
      if (userDoc == null) {
        return;
      } else {
        setState(() {
          name = userDoc.get('name');
          email = userDoc.get('email');
          phoneNumber = userDoc.get('phoneNumber');
          imageUrl = userDoc.get('userImage');
          secteur = userDoc.get('secteur');
          Timestamp joinedAtTimeStamp = userDoc.get('createdAt');
          var joinedDate = joinedAtTimeStamp.toDate();
          joinedAt = '${joinedDate.year}-${joinedDate.month}-${joinedDate.day}';
        });

        User? user = _auth.currentUser;
        final _uid = user!.uid;
        setState(() {
          _isSameUser = _uid == widget.userId;
        });
      }
    } catch (error) {
      print(error);
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBarForApp(
          indexNum: 4,
        ),
        backgroundColor: const Color.fromRGBO(255, 236, 239, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(55, 41, 72, 1),
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(LineAwesomeIcons.angle_left),
          ),
          title: const Text(
            tProfile,
            // style: TextStyle(color: Colors.red),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(LineAwesomeIcons.sun))
          ],
        ),
        body: _isSameUser == true
            ? SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: Padding(
                              padding: const EdgeInsets.all(11.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageUrl.isNotEmpty
                                        ? NetworkImage(imageUrl)
                                        : const NetworkImage(
                                            'https://media.istockphoto.com/id/1209654046/vector/user-avatar-profile-icon-black-vector-illustration.jpg?s=612x612&w=0&k=20&c=EOYXACjtZmZQ5IsZ0UUp1iNmZ9q2xl1BD1VvN6tZ2UI='),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      RatingBar.builder(
                        initialRating: averageRating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) {
                          // Calculate the color of the star icon based on the average rating
                          if (averageRating >= _.toDouble()) {
                            return const Icon(
                              Icons.star,
                              color: Colors.amber,
                            );
                          } else if (averageRating >= _.toDouble() - 0.5) {
                            return const Icon(
                              Icons.star_half,
                              color: Colors.amber,
                            );
                          } else {
                            return const Icon(
                              Icons.star_border,
                              color: Colors.amber,
                            );
                          }
                        },
                        onRatingUpdate: (rating) {},
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 10,
                      ),
                      ProfileMenueWidget(
                        title: "mes experiences",
                        icon: LineAwesomeIcons.cog,

                        // endIcon: ,
                        textColor: Colors.black,
                        onPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ExperiencePage(
                                      userId: widget.userId,
                                    )),
                          );
                        },
                      ),
                      ProfileMenueWidget(
                        title: "Modifier Profile",
                        icon: LineAwesomeIcons.user_edit,
                        textColor: Colors.black,
                        onPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => updateProfile(
                                      userId: widget.userId,
                                    )),
                          );
                        },
                      ),
                      ProfileMenueWidget(
                        title: "mes demandes",
                        icon: LineAwesomeIcons.newspaper,
                        textColor: Colors.black,
                        onPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const myJob()),
                          );
                        },
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 10,
                      ),
                      ProfileMenueWidget(
                        title: "mes offres",
                        textColor: Colors.black,
                        icon: LineAwesomeIcons.briefcase,
                        onPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const myOffers()),
                          );
                        },
                      ),
                      ProfileMenueWidget(
                        title: "deconnexion",
                        icon: LineAwesomeIcons.alternate_sign_out,
                        textColor: Colors.red,
                        onPress: () {
                          _logout(context);
                        },
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: Padding(
                              padding: const EdgeInsets.all(11.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageUrl.isNotEmpty
                                        ? NetworkImage(imageUrl)
                                        : const NetworkImage(
                                            'https://media.istockphoto.com/id/1209654046/vector/user-avatar-profile-icon-black-vector-illustration.jpg?s=612x612&w=0&k=20&c=EOYXACjtZmZQ5IsZ0UUp1iNmZ9q2xl1BD1VvN6tZ2UI='),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Text(secteur),
                      const SizedBox(
                        height: 10,
                      ),
                      RatingBar.builder(
                        initialRating: rate,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) {
                          // Calculate the color of the star icon based on the average rating
                          if (averageRating >= _.toDouble()) {
                            return const Icon(
                              Icons.star,
                              color: Colors.amber,
                            );
                          } else if (averageRating >= _.toDouble() - 0.5) {
                            return const Icon(
                              Icons.star_half,
                              color: Colors.amber,
                            );
                          } else {
                            return const Icon(
                              Icons.star_border,
                              color: Colors.amber,
                            );
                          }
                        },
                        onRatingUpdate: (rating) {
                          // rateuser(rating);
                          userDataInstance.rateuser(rating, widget.userId);
                        },
                      ),
                      Text("i work on" + " " + secteur),

                      // Text(name!, style: TextStyle(color: Colors.amber)),
                      const SizedBox(
                        height: 20,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 10,
                      ),
                      ProfileMenueWidget(
                        title: "experience",
                        icon: LineAwesomeIcons.newspaper,
                        textColor: Colors.black,
                        onPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ExperiencePage(
                                      userId: widget.userId,
                                    )),
                          );
                        },
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(email),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(phoneNumber),

                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _contactBy(
                            color: Colors.red,
                            fct: () {
                              _mailTo();
                            },
                            icon: Icons.mail_outline,
                          ),
                          _contactBy(
                            color: Colors.purple,
                            fct: () {
                              _callPhoneNumber();
                            },
                            icon: Icons.call,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                          nomreceiver: name.toString(),
                                          imageReceiver: imageUrl,
                                          idReceiver: widget.userId,
                                        )),
                              );
                            },
                            child: const Icon(Icons.message),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
  }
}
