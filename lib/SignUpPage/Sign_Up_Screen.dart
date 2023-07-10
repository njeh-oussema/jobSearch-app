import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Data/secteurData.dart';
import 'package:frontend/Data/villeData.dart';
import 'package:frontend/Data/userData.dart';
import 'package:frontend/services/global_methos.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {
  final TextEditingController _fullNameController =
      TextEditingController(text: '');

  final TextEditingController _emailController =
      TextEditingController(text: '');

  final TextEditingController _passwordcontroller =
      TextEditingController(text: '');

  final TextEditingController _phoneNumberController =
      TextEditingController(text: '');

  final TextEditingController _adresseController =
      TextEditingController(text: '');
  final TextEditingController _secteurCategory =
      TextEditingController(text: '');
  //focus
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _positionCPFFocusNode = FocusNode();

  final _SignUpFormKey = GlobalKey<FormState>();
  bool _obscureText = true;
  File? imageFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  String? imageurl;
  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordcontroller.dispose();
    _phoneNumberController.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _positionCPFFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

/* this is the function that show u when u click in (+) button to add an image 
 from the gallery or from the camera of th device  */
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
                        color: const Color.fromRGBO(55, 41, 72, 1),
                      ),
                    ),
                    Text(
                      'camera',
                      style:
                          TextStyle(color: const Color.fromRGBO(55, 41, 72, 1)),
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
                        color: const Color.fromRGBO(55, 41, 72, 1),
                      ),
                    ),
                    Text(
                      'Gallery',
                      style:
                          TextStyle(color: const Color.fromRGBO(55, 41, 72, 1)),
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

//we use the depandancie image_picker that make us to select image from device
  void _getFormCamera() async {
    XFile? PickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    //we make an appel to the function crop
    _cropImage(PickedFile!.path);

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

  Future<bool> checkIfEmailExists(String email) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    try {
      List<String> signInMethods =
          await _firebaseAuth.fetchSignInMethodsForEmail(email);
      if (signInMethods.isNotEmpty) {
        // Email already exists
        return true;
      } else {
        // Email does not exist
        return false;
      }
    } on FirebaseAuthException catch (e) {
      print('Failed to check email existence: ${e.message}');
      return false;
    }
  }

  _showTaskCategorieDialog({required Size size}) {
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
                    stream: /* FirebaseFirestore.instance
                        .collection('locations')
                        .snapshots(), */
                        vileInstance.getVille(),
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
                                _adresseController.text = doc['name'];
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

  villeData vileInstance = villeData();

  _addLocation() {
    String _text = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('new location'),
          content: TextField(
            controller: _adresseController,
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

                vileInstance
                    .addLocation(_adresseController.text.trim().toLowerCase());
              },
            ),
          ],
        );
      },
    );
  }

  _addsecteur() {
    String _text = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('new sector'),
          content: TextField(
            controller: _secteurCategory,
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
                    .addSecteur(_secteurCategory.text.trim().toLowerCase());
              },
            ),
          ],
        );
      },
    );
  }

  secteurData secteurInstance = secteurData();
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
                                _secteurCategory.text = doc['name'];
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

  void onSignUp() {
    UserData signUpMethod = UserData();
    final isValid = _SignUpFormKey.currentState!.validate;
    if (isValid) {
      if (imageFile == null) {
        GlobalMethode.showErrorDialog(error: 'ajouter image', ctx: context);
        return;
      }
      signUpMethod.submitFormOnSignUp1(
          "users",
          _passwordcontroller,
          _emailController,
          _adresseController,
          _secteurCategory,
          _fullNameController,
          _phoneNumberController,
          imageFile,
          context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 236, 239, 1),
      body: Stack(children: [
        Container(
          color: const Color.fromRGBO(255, 236, 239, 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
            child: ListView(children: [
              Form(
                key: _SignUpFormKey,
                child: Column(children: [
                  GestureDetector(
                    onTap: () {
                      _showImageDialog();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: size.width * 0.24,
                        height: size.width * 0.24,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: const Color.fromRGBO(55, 41, 72, 1),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: imageFile == null
                              ? const Icon(
                                  Icons.camera_enhance_sharp,
                                  color: const Color.fromRGBO(55, 41, 72, 1),
                                  size: 30,
                                )
                              : Image.file(
                                  imageFile!,
                                  fit: BoxFit.fill,
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(_emailFocusNode),
                    keyboardType: TextInputType.name,
                    controller: _fullNameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'This Field is missing ';
                      } else {
                        return null;
                      }
                    },
                    style:
                        const TextStyle(color: Color.fromRGBO(55, 41, 72, 1)),
                    decoration: const InputDecoration(
                        hintText: 'Name',
                        hintStyle:
                            TextStyle(color: Color.fromRGBO(55, 41, 72, 1)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(55, 41, 72, 1))),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(55, 41, 72, 1))),
                        errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red))),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(_passFocusNode),
                    keyboardType: TextInputType.emailAddress,
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
                    style:
                        const TextStyle(color: Color.fromRGBO(55, 41, 72, 1)),
                    decoration: const InputDecoration(
                        hintText: 'Email',
                        hintStyle:
                            TextStyle(color: Color.fromRGBO(55, 41, 72, 1)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(55, 41, 72, 1))),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(55, 41, 72, 1))),
                        errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red))),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context)
                        .requestFocus(_phoneNumberFocusNode),
                    keyboardType: TextInputType.visiblePassword,
                    controller: _passwordcontroller,
                    obscureText: !_obscureText,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 7) {
                        return 'Please enter a valid password with at least 7 characters';
                      }
                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        return 'Password must contain at least one uppercase letter';
                      }
                      if (!RegExp(r'\d').hasMatch(value)) {
                        return 'Password must contain at least one number';
                      }
                      return null;
                    },
                    style:
                        const TextStyle(color: Color.fromRGBO(55, 41, 72, 1)),
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        child: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color.fromRGBO(55, 41, 72, 1),
                        ),
                      ),
                      hintText: 'Password',

                      hintStyle:
                          const TextStyle(color: Color.fromRGBO(55, 41, 72, 1)),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromRGBO(55, 41, 72, 1)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromRGBO(55, 41, 72, 1)),
                      ),
                      errorBorder: const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromRGBO(55, 41, 72, 1)),
                      ),
                      errorStyle: const TextStyle(color: Colors.red),
                      // Helper text to display password requirements
                      helperText:
                          'Must contain at least one uppercase letter and one number',
                      helperStyle:
                          const TextStyle(color: Color.fromRGBO(55, 41, 72, 1)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => FocusScope.of(context)
                        .requestFocus(_positionCPFFocusNode),
                    keyboardType: TextInputType.phone,
                    controller: _phoneNumberController,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 8) {
                        return 'please verify your phone number ';
                      }
                      if (!RegExp(r'^(2|4|9|5|7)').hasMatch(value)) {
                        return 'Phone number must start with 2,4,9,5, or 7';
                      }
                    },
                    maxLength: 8,
                    style:
                        const TextStyle(color: Color.fromRGBO(55, 41, 72, 1)),
                    decoration: const InputDecoration(
                        hintText: 'Phone Number',
                        hintStyle:
                            TextStyle(color: Color.fromRGBO(55, 41, 72, 1)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(55, 41, 72, 1))),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(55, 41, 72, 1))),
                        errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red))),
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () => _showTaskCategorieDialog(size: size),
                    child: AbsorbPointer(
                      child: TextFormField(
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => FocusScope.of(context)
                            .requestFocus(_positionCPFFocusNode),
                        keyboardType: TextInputType.text,
                        controller: _adresseController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'please verify your location ';
                          } else {
                            return null;
                          }
                        },
                        style: const TextStyle(
                            color: Color.fromRGBO(55, 41, 72, 1)),
                        decoration: const InputDecoration(
                          hintText: 'Adresse ',
                          hintStyle:
                              TextStyle(color: Color.fromRGBO(55, 41, 72, 1)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(55, 41, 72, 1))),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(55, 41, 72, 1))),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  GestureDetector(
                    onTap: () => _showTaskSecteurDialog(size: size),
                    child: AbsorbPointer(
                      child: TextFormField(
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => FocusScope.of(context)
                            .requestFocus(_positionCPFFocusNode),
                        keyboardType: TextInputType.text,
                        controller: _secteurCategory,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'please verify your sector ';
                          } else {
                            return null;
                          }
                        },
                        style: const TextStyle(
                            color: Color.fromRGBO(55, 41, 72, 1)),
                        decoration: const InputDecoration(
                            hintText: 'secteur ',
                            hintStyle:
                                TextStyle(color: Color.fromRGBO(55, 41, 72, 1)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(55, 41, 72, 1))),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(55, 41, 72, 1))),
                            errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red))),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  _isLoading
                      ? Center(
                          child: Container(
                            width: 70,
                            height: 70,
                            child: const CircularProgressIndicator(),
                          ),
                        )
                      : MaterialButton(
                          onPressed: () {
                            //create submit Form On SignUp
                            // _submitFormOnSignUp();
                            onSignUp();
                          },
                          color: const Color.fromRGBO(55, 41, 72, 1),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Sign up',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                )
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: RichText(
                        text: TextSpan(children: [
                      const TextSpan(
                          text: 'Already have an account ?',
                          style: TextStyle(
                              color: Color.fromRGBO(20, 10, 20, 2),
                              fontWeight: FontWeight.normal,
                              fontSize: 16)),
                      const TextSpan(text: '      '),
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.canPop(context)
                                ? Navigator.pop(context)
                                : null,
                          text: 'Login',
                          style: const TextStyle(
                              color: Color.fromRGBO(20, 10, 20, 2),
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ])),
                  )
                ]),
              )
            ]),
          ),
        )
      ]),
    );
  }
}
