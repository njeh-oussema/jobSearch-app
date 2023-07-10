import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/Data/secteurData.dart';
import 'package:frontend/Data/userData.dart';
import 'package:frontend/Data/villeData.dart';
import 'package:frontend/myProfile/changePassword.dart';
import 'package:frontend/myProfile/profilee_screeen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../Widgets/bottom_nav_bar.dart';
import '../../services/global_methos.dart';
import 'profile_menu.dart';

class updateProfile extends StatefulWidget {
  // const updateProfile({super.key});
  final String userId;
  const updateProfile({required this.userId});
  @override
  State<updateProfile> createState() => _updateProfileState();
}

final TextEditingController _fullNameController =
    TextEditingController(text: '');

final TextEditingController _emailController = TextEditingController(text: '');
final TextEditingController _locationController =
    TextEditingController(text: '');
final TextEditingController _phoneNumberController =
    TextEditingController(text: '');
final TextEditingController _secteurController =
    TextEditingController(text: '');
final TextEditingController password = TextEditingController();

class _updateProfileState extends State<updateProfile> {
  final FirebaseAuth _aut = FirebaseAuth.instance;
  String? name;
  String email = '';
  String phoneNumber = '';
  String imageUrl = '';
  String joinedAt = '';
  String adresse = '';
  String secteur = '';
  final edit = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isSameUser = false;
  File? imageFile;
  // final picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(user!.email);
    getUserData();
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Please choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  _getFormCamera();
                },
                child: Row(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.camera,
                        color: Colors.purple,
                      ),
                    ),
                    Text(
                      'camera',
                      style: TextStyle(color: Colors.purple),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  _getFormGallery();
                },
                child: Row(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.image,
                        color: Colors.purple,
                      ),
                    ),
                    Text(
                      'Gallery',
                      style: TextStyle(color: Colors.purple),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  _addsecteur() {
    String _text = '';
    // TextEditingController Comment_Controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('new sector'),
          content: TextField(
            controller: _secteurController,
            decoration: const InputDecoration(
              hintText: 'Entrez votre texte ici',
            ),
          ),
          actions: [
            MaterialButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            MaterialButton(
              child: const Text('Valider'),
              onPressed: () async {
                Navigator.of(context).pop();
                secteurInstance
                    .addSecteur(_secteurController.text.trim().toLowerCase());
                /* persistanInstance
                    .addSecteur(_secteurCategory.text.trim().toLowerCase()); */
              },
            ),
          ],
        );
      },
    );
  }

  _addLocation() {
    String _text = '';
    // TextEditingController Comment_Controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('new location'),
          content: TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              hintText: 'Entrez votre texte ici',
            ),
          ),
          actions: [
            MaterialButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            MaterialButton(
              child: const Text('Valider'),
              onPressed: () async {
                Navigator.of(context).pop();
                final sectorId = const Uuid().v4();
                /*   await FirebaseFirestore.instance
                    .collection('locations')
                    .doc(sectorId)
                    .set({
                  'id': sectorId,
                  'name': _adresseController.text,
                }); */

                /*   persistanInstance
                    .addLocation(_adresseController.text.trim().toLowerCase()); */
                villInstance
                    .addLocation(_locationController.text.trim().toLowerCase());
              },
            ),
          ],
        );
      },
    );
  }

  _showLocation({required Size size}) {
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
                    stream: villInstance
                        .getVille() /* FirebaseFirestore.instance
                        .collection('locations')
                        .snapshots() */
                    ,
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
                                _locationController.text = doc['name'];
                              });
                              //close the list after you choice
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
                        _addLocation();
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

//we use the depandancie image_picker that make us to select image from device
  void _getFormCamera() async {
    XFile? PickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    //we make an appel to the function crop
    _cropImage(PickedFile!.path);
    setState(() {
      // userImage = PickedFile as String?;
      // imageFile = PickedFile as File?;
    });
    Navigator.pop(context);
  }

  void _getFormGallery() async {
    XFile? PickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    //we make an appel to the function crop
    _cropImage(PickedFile!.path);
    Navigator.pop(context);
  }

/* function bch baad ma te5tar el image fil gallerie walla te5o teswira bil cam
 te5tar el taille mte3 el taswira */
  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);
    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  villeData villInstance = villeData();
  secteurData secteurInstance = secteurData();
  _showSecteur({required Size size}) {
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
                    stream: secteurInstance
                        .getSecteur() /* FirebaseFirestore.instance
                        .collection('secteur')
                        .snapshots() */
                    ,
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
                                _secteurController.text = doc['name'];
                              });
                              //close the list after you choice
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
                        _addsecteur();
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

  // UserData userDataInstance = UserData();
  void _updateProfile() async {
    final isValid = edit.currentState!.validate;
    // AuthCredential credential = EmailAuthProvider.credential(email: user!.email, password: 'passwordProvidedByUser');

    if (isValid) {
      setState(() {
        _isLoading = true;
      });

      try {
        final User? user = _aut.currentUser;
        final _uid = user!.uid;

        if (imageFile != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('userImage')
              .child(_uid + '.jpg');
          await ref.putFile(imageFile!);
          imageUrl = await ref.getDownloadURL();
        }
        await updateCommentsByUserId2(_uid, _fullNameController.text.trim(),
            imageUrl, _locationController.text.trim());
        updateDataOffre(_uid, _fullNameController.text.trim(), imageUrl);

        if (_fullNameController.text.trim().isNotEmpty &&
            _emailController.text.trim().isNotEmpty &&
            _locationController.text.trim().isNotEmpty &&
            _phoneNumberController.text.trim().isNotEmpty) {
          final emailSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: _emailController.text.trim())
              .get();
          if (emailSnapshot.docs.isNotEmpty &&
              _emailController.text.trim() != email) {
            GlobalMethode.showErrorDialog(
                error: 'email deja existe', ctx: context);
          } else {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(_uid)
                .update({
              'name': _fullNameController.text.trim(),
              'phoneNumber': _phoneNumberController.text.trim(),
              'location': _locationController.text.trim(),
              'secteur': _secteurController.text.trim(),
              'userImage': imageUrl,
              'email': _emailController.text.trim()
            });
          }

          print(user.email);
// /*         await user.updatePassword(_passwordcontroller.text.trim());
          AuthCredential credential = EmailAuthProvider.credential(
              email: user.email ?? 'defaultEmail', password: password.text);
          await user.reauthenticateWithCredential(credential);
          await user.updateEmail(_emailController.text.trim());

          // ignore: use_build_context_synchronously
          password.clear();
          // ignore: use_build_context_synchronously
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileSceen(
                  userId: widget.userId,
                ),
              ));
          /*    Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileSceen(
                userId: widget.userId,
              ),
            ));  */
        } else {
          GlobalMethode.showErrorDialog(error: 'invalid value', ctx: context);
        }
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        GlobalMethode.showErrorDialog(error: error.toString(), ctx: context);
      }
    }
  }

  Future<void> updateCommentsByUserId2(
      String userId, String newName, String newImage, ville) async {
    try {
      final QuerySnapshot jobsSnapshot = await FirebaseFirestore.instance
          .collection(
              'demandeTravail') // Assuming 'jobs' is the collection name
          .get();

      final List<QueryDocumentSnapshot> jobDocs = jobsSnapshot.docs;

      for (var doc in jobDocs) {
        if (doc['uploadedBy'] == userId) {
          await FirebaseFirestore.instance
              .collection('demandeTravail')
              .doc(doc.id)
              .update({'name': newName, 'userImage': newImage, 'ville': ville});
        }
        var jobComments = List<Map<String, dynamic>>.from(doc['commentaire']);

        for (var i = 0; i < jobComments.length; i++) {
          if (jobComments[i]['userId'] == userId) {
            jobComments[i]['name'] = newName;
            jobComments[i]['userImageUrl'] = newImage;
          }
        }

        await FirebaseFirestore.instance
            .collection('demandeTravail')
            .doc(doc.id)
            .update({'commentaire': jobComments});
      }
    } catch (e) {
      print('Error updating comments: $e');
    }
  }

  Future<void> updateDataOffre(
      String userId, String newName, String newImage) async {
    try {
      final QuerySnapshot offresnapshot =
          await FirebaseFirestore.instance.collection('offres').get();
      final List<QueryDocumentSnapshot> offerDocs = offresnapshot.docs;

      for (var doc in offerDocs) {
        if (doc['worker_id'] == userId) {
          await FirebaseFirestore.instance
              .collection('offres')
              .doc(doc.id)
              .update({
            'worker_name': newName,
            'worker_image': newImage,
          }); // Assuming 'worker_name' is the name field for worker
        }
        if (doc['id_poster'] == userId) {
          await FirebaseFirestore.instance
              .collection('offres')
              .doc(doc.id)
              .update({
            'name_poster': newName,
            'image_poster': newImage
          }); // Assuming 'poster_name' is the name field for poster
        }
      }
    } catch (e) {
      print('Error updating name in offre: $e');
    }
  }

/*   Future<void> updateDataOffre(String userId, String newName) async {
    try {
      final QuerySnapshot offresnapshot =
          await FirebaseFirestore.instance.collection('offres').get();
      final List<QueryDocumentSnapshot> offerDocs = offresnapshot.docs;

      for (var doc in offerDocs) {
        if (doc['worker_id'] == userId) {

          doc['worker_name']=="thh";
          await FirebaseFirestore.instance
              .collection('offres')
              .doc(userId)
              .update(
                  {}); // Assuming 'worker_name' is the name field for worker
        }
        if (doc['id_poster'] == userId) {
          doc['worker_name']=="thh";

          await FirebaseFirestore.instance
              .collection('offres')
              .doc(userId)
              .update({
            // 'name_poster': newName
          }); // Assuming 'poster_name' is the name field for poster
        }
      }
    } catch (e) {
      print('Error updating name in offre: $e');
    }
  } */

  void getUserData() async {
    try {
      _isLoading = true;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc == null) {
        return;
      } else {
        setState(() {
          name = userDoc.get('name');
          email = userDoc.get('email');
          phoneNumber = userDoc.get('phoneNumber');
          imageUrl = userDoc.get('userImage');
          adresse = userDoc.get('location');
          secteur = userDoc.get('secteur');
          Timestamp joinedAtTimeStamp = userDoc.get('createdAt');
          var joinedDate = joinedAtTimeStamp.toDate();
          joinedAt = '${joinedDate.year}-${joinedDate.month}-${joinedDate.day}';
        });
        _fullNameController.text = name ?? '';
        _emailController.text = email;
        _phoneNumberController.text = phoneNumber;
        _locationController.text = adresse;
        _secteurController.text = secteur;

        User? user = _aut.currentUser;
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
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBarForApp(
        indexNum: 4,
      ),
      backgroundColor: Color.fromRGBO(255, 236, 239, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(55, 41, 72, 1),
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(LineAwesomeIcons.angle_left),
        ),
        title: const Text(
          tEditProfile,
        ),
      ),
      body: SingleChildScrollView(
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
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          _showImageDialog();
                        },
                        child: Container(
                          width: size.width * 0.26,
                          height: size.width * 0.26,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageFile != null
                                  ? FileImage(imageFile!)
                                  : NetworkImage(imageUrl.isNotEmpty
                                          ? imageUrl
                                          : 'https://static.vecteezy.com/system/resources/previews/000/439/863/original/vector-users-icon.jpg')
                                      as ImageProvider<Object>,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    )),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      // pickImage();
                      _showImageDialog();
                    },
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: tAccentColor.withOpacity(0.1)),
                      child: Icon(
                        LineAwesomeIcons.alternate_pencil,
                        size: 20,
                        color: tPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Form(
              key: edit,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 5),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        label: const Text("nom "),
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        floatingLabelStyle:
                            const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(120)),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(width: 1, color: Colors.black),
                        ),
                        // InputDecorationTheme: TTextFormFieldTheme.LightInputDecorationTheme
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value!.isEmpty ||
                            !value.contains('@') ||
                            !value.endsWith('.com')) {
                          return 'please enter a valid email ';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        label: const Text("email"),
                        prefixIcon: const Icon(Icons.email),
                        floatingLabelStyle:
                            const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(120)),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(width: 1, color: Colors.black),
                        ),
                        // InputDecorationTheme: TTextFormFieldTheme.LightInputDecorationTheme
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextFormField(
                      onTap: () {
                        _showLocation(size: size);
                      },
                      controller: _locationController,
                      readOnly: true,
                      decoration: InputDecoration(
                        label: const Text("ville"),
                        prefixIcon: const Icon(Icons.local_activity),
                        floatingLabelStyle:
                            const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(120)),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(width: 1, color: Colors.black),
                        ),
                        // InputDecorationTheme: TTextFormFieldTheme.LightInputDecorationTheme
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextFormField(
                      onTap: () {
                        _showSecteur(size: size);
                      },
                      controller: _secteurController,
                      readOnly: true,
                      decoration: InputDecoration(
                        label: const Text("secteur"),
                        prefixIcon: const Icon(Icons.local_activity),
                        floatingLabelStyle:
                            const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(120)),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(width: 1, color: Colors.black),
                        ),
                        // InputDecorationTheme: TTextFormFieldTheme.LightInputDecorationTheme
                      ),
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _phoneNumberController,
                      maxLength: 8,
                      // validator: ,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 8) {
                          return 'please verify your phone number ';
                        }
                        if (!RegExp(r'^(2|4|9|5|7)').hasMatch(value)) {
                          return 'Phone number must start with 2,4,9,5, or 7';
                        }
                      },
                      decoration: InputDecoration(
                        label: const Text("numero de telephone"),
                        prefixIcon: const Icon(Icons.phone_android),
                        floatingLabelStyle:
                            const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(120)),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(width: 1, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      obscureText: true,
                      controller: password,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'ecrire le password ';
                        }
                      },
                      decoration: InputDecoration(
                        label: const Text("Password"),
                        prefixIcon: const Icon(Icons.password),
                        floatingLabelStyle:
                            const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(120)),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(width: 1, color: Colors.black),
                        ),
                        // InputDecorationTheme: TTextFormFieldTheme.LightInputDecorationTheme
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      child: SizedBox(
                        width: 260,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            /*     userDataInstance.updateProfile(
                                _fullNameController.text.trim(),
                                _phoneNumberController.text.trim(),
                                _locationController.text.trim(),
                                _secteurController.text.trim(),
                                imageFile,
                                _emailController.text.trim());*/
                            _updateProfile();
                            /*     updateCommentsByUserId(user!.uid,
                                _fullNameController.text.trim(), imageUrl); */
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(55, 41, 72, 1),
                              side: BorderSide.none,
                              shape: const StadiumBorder()),
                          child: const Text(
                            "Update",
                            style: TextStyle(
                                color: Color.fromRGBO(225, 215, 198, 1)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      child: SizedBox(
                        width: 260,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            // _updateProfile();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangePasswordScreen(),
                                ));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(55, 41, 72, 1),
                              side: BorderSide.none,
                              shape: const StadiumBorder()),
                          child: const Text(
                            "change Password",
                            style: TextStyle(
                                color: Color.fromRGBO(225, 215, 198, 1)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}
