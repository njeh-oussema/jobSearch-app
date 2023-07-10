import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Data/secteurData.dart';
import 'package:frontend/services/global_methos.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/Data/demandeData.dart';
import '../Widgets/bottom_nav_bar.dart';

class UploadJobNow extends StatefulWidget {
  const UploadJobNow({super.key});

  @override
  State<UploadJobNow> createState() => _UploadJobNowState();
}

class _UploadJobNowState extends State<UploadJobNow> {
  final TextEditingController _jobCategorieController =
      TextEditingController(text: 'secteur');

  final TextEditingController _jobTitleController =
      TextEditingController(text: '');

  // ignore: non_constant_identifier_names
  final TextEditingController _JobDescripController =
      TextEditingController(text: '');

  // ignore: non_constant_identifier_names
  final TextEditingController _JobDeadLineController =
      TextEditingController(text: 'DeadLine Date');

  final _formKey = GlobalKey<FormState>();
  DateTime? picked;
  Timestamp? deadLineDateTimeStamp;
  final bool _isLoading = false;
  String name = "";
  String userImage = "";
  String location = "";
  bool shouldUploadImages = true;
  List<File> images = [];

  List<File> selectedImages = [];
  secteurData secteurInstance = secteurData();

  @override
  void dispose() {
    super.dispose();
    _jobCategorieController.dispose();
    _jobTitleController.dispose();
    _JobDescripController.dispose();
    _JobDeadLineController.dispose();
  }

  Widget _textTitles({required String label}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _textFormFields(
      {required String valueKey,
      required TextEditingController controller,
      required bool enabled,
      required Function fct,
      required int maxLength,
      required Text txt,
      required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'Value is missing';
            }
            return null;
          },
          controller: controller,
          //this attribute for keyboard
          enabled: enabled,
          key: ValueKey(valueKey),
          style: const TextStyle(color: Color.fromRGBO(55, 41, 72, 1)),

          //this line make the textField of description is biggest textFiels
          maxLines: valueKey == 'JobDescription' ? 3 : 1,
          maxLength: maxLength,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            label: txt,
            prefixIcon: Icon(icon),
            floatingLabelStyle: const TextStyle(color: Colors.black),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(width: 1, color: Colors.black),
            ),
            // InputDecorationTheme: TTextFormFieldTheme.LightInputDecorationTheme
          ),
        ),
      ),
    );
  }

  _showTaskSecteurDialog({required Size size}) {
    Future.delayed(
      Duration.zero,
      () {
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                backgroundColor: Colors.black54,
                content: SizedBox(
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
                                _jobCategorieController.text = doc['name'];
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
                ],
              );
            });
      },
    );
  }

  Future<List<File>> pickImages() async {
    // ignore: deprecated_member_use
    final pickedFiles = await ImagePicker().getMultiImage();
    if (pickedFiles != null) {
      return pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
    }
    return [];
  }

// Function to upload a single file to Firebase Storage
  Future<String> uploadImageToFirebase(File image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("images/${DateTime.now().toString()}");
    UploadTask uploadTask = ref.putFile(image);

    await uploadTask.whenComplete(() => null);
    return await ref.getDownloadURL();
  }

  Future<void> pickAndUploadImages() async {
    List<File> images = await pickImages();
    for (File image in images) {
      String imageUrl = await uploadImageToFirebase(image);
    }

    setState(() {
      selectedImages = images;
    });
  }

  void _pickDateDialog() async {
    //showDatePicker is a method that makeuser to show a calender for the user to select a date
    picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        // text field is updated with the selected date
        _JobDeadLineController.text =
            '${picked!.year}- ${picked!.month} - ${picked!.day}';

        deadLineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(
            picked!.microsecondsSinceEpoch);
      });
    }
  }

//to make the object job have the name, location and the imae of the poste
  void getMyData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    name = userDoc.get('name');
    userImage = userDoc.get('userImage');
    location = userDoc.get('location');
  }

  Future<void> uploadJobData() async {
    jobData jobDataInstance = jobData();
    final isValid = _formKey.currentState!.validate;

    if (isValid) {
      if (_JobDeadLineController.text == 'DeadLine Date' ||
          _jobCategorieController.text == 'secteur') {
        GlobalMethode.showErrorDialog(error: 'champ vide !', ctx: context);
        return;
      }
      List<String> imageUrls = [];

      if (shouldUploadImages == true) {
        // selectedImages = await pickImages();
        if (selectedImages.isNotEmpty) {
          for (File image in selectedImages) {
            String imageUrl = await uploadImageToFirebase(image);
            imageUrls.add(imageUrl);
          }
        }
        if (selectedImages.isEmpty && shouldUploadImages == true) {
          selectedImages = await pickImages();

          for (File image in selectedImages) {
            String imageUrl = await uploadImageToFirebase(image);
            imageUrls.add(imageUrl);
          }
        }
      }
      jobDataInstance.ajoutrerDemande(
          _jobTitleController,
          _jobCategorieController,
          _JobDescripController,
          _JobDeadLineController,
          deadLineDateTimeStamp,
          name,
          userImage,
          location,
          imageUrls);
      setState(() {
        selectedImages = [];
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade300, Colors.blueAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.2, 0.9],
        ),
      ),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBarForApp(
          indexNum: 2,
        ),
        backgroundColor: const Color.fromRGBO(255, 236, 239, 1),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  /*    it is a class to devide between the widget t(they have 4 attributes
                   [height, thikness, indent,endIndent]) */
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // _textTitles(label: 'Job Category'),
                            _textFormFields(
                              valueKey: 'JobCategory',
                              controller: _jobCategorieController,
                              enabled: false,
                              fct: () {
                                _showTaskSecteurDialog(size: size);
                              },
                              maxLength: 100,
                              txt: const Text("secteur"),
                              icon: Icons.category,
                            ),

                            const SizedBox(
                              height: 20,
                            ),
                            _textFormFields(
                                valueKey: 'JobTitle',
                                controller: _jobTitleController,
                                enabled: true,
                                fct: () {},
                                maxLength: 100,
                                icon: Icons.title,
                                txt: const Text("titre")),

                            const SizedBox(
                              height: 20,
                            ),
                            _textFormFields(
                                icon: Icons.description,
                                valueKey: 'JobDescription',
                                controller: _JobDescripController,
                                enabled: true,
                                fct: () {},
                                maxLength: 100,
                                txt: const Text("description")),
                            const SizedBox(
                              height: 20,
                            ),
                            _textFormFields(
                                icon: Icons.date_range,
                                valueKey: 'JobDeadline',
                                controller: _JobDeadLineController,
                                enabled: false,
                                fct: () {
                                  _pickDateDialog();
                                },
                                maxLength: 100,
                                txt: const Text("deadLine")),

                            const SizedBox(
                              height: 20,
                            ),
                            SwitchListTile(
                              title: const Text("Upload images?"),
                              value: shouldUploadImages,
                              onChanged: (bool value) {
                                setState(() {
                                  shouldUploadImages = value;
                                });
                              },
                            ),
                            shouldUploadImages == true
                                ? Row(
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(
                                              55,
                                              41,
                                              72,
                                              1), // Set the background color to red
                                        ),
                                        onPressed: pickAndUploadImages,
                                        child: const Text("Select Images"),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Visibility(
                                        visible: selectedImages.isNotEmpty,
                                        child: SizedBox(
                                          height:
                                              100, // Adjust this value according to your need
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5, // Take up 50% of the screen width
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: selectedImages.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image.file(
                                                  selectedImages[index],
                                                  fit: BoxFit.cover,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text("")
                          ],
                        )),
                  ),
                  Center(
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 30, top: 20),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : GestureDetector(
                                child: SizedBox(
                                  width: 260,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // _updateProfile();
                                      // _uploadTask();
                                      uploadJobData();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color.fromRGBO(55, 41, 72, 1),
                                        side: BorderSide.none,
                                        shape: const StadiumBorder()),
                                    child: const Text(
                                      "ajouter demande",
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(225, 215, 198, 1)),
                                    ),
                                  ),
                                ),
                              )),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
