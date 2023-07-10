import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/Data/userData.dart';
import 'package:frontend/demande/Detail_demande/comments_widget.dart';
import 'package:frontend/Data/commentData.dart';
import 'package:frontend/Data/demandeData.dart';
import 'package:frontend/demande/demande_screen.dart';
import 'package:frontend/Data/offreData.dart';
import 'package:frontend/services/global_methos.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';
import 'package:photo_view/photo_view.dart';
import '../../myProfile/profilee_screeen.dart';

class JobDetailScreen extends StatefulWidget {
  final String uploadedBy;
  final String jobId;
  final String userId; // add this line

  JobDetailScreen(
      {required this.jobId, required this.uploadedBy, required this.userId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _commentController = TextEditingController();

  bool _isCommenting = false;
  String? userId;
  String? authorName;
  String? userImageUrl;
  String? jobCategory;
  String? jobDescription;
  String? jobTitle;
  bool? status;
  Timestamp? postedDateTimeStamp;
  Timestamp? deadlineDateTimeStamp;
  String? postedDate;
  String? deadlineDate;
  String? locationCompany = '';
  String? emailCompany;
  int applicants = 0;
  bool isDeadlineAvailable = false;
  bool showComment = false;
  List<String> imageUrls = [];
  jobData jobDataInstance = jobData();
  commentData commentDataInstance = commentData();
  String? myName;
  String? image;
  String curr = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController message_Controller = TextEditingController();
  TextEditingController prix_Controller = TextEditingController();
  TextEditingController date_Controller = TextEditingController();
  final GlobalKey<FormState> offerKey = GlobalKey<FormState>();
  DateTime? picked;
  Timestamp? deadLineDateTimeStamp;

  offreData offerDataInstance = offreData();

  Future<int> getNumberOffer(String idWorker, String idJob) async {
    final QuerySnapshot<Map<String, dynamic>> offerDoc = await FirebaseFirestore
        .instance
        .collection('offres')
        .where('worker_id', isEqualTo: idWorker)
        .where('job_id', isEqualTo: idJob)
        .get();

    int nbr = offerDoc.docs.length;
    return nbr;
  }

  void _uploadOffre() async {
    final _offreId = const Uuid().v4();
    /* applicants++;
    addNewApplicant(); */

    offerDataInstance.ajouterOffre(
        widget.jobId,
        myName,
        image,
        jobTitle,
        userId,
        authorName,
        userImageUrl,
        message_Controller.text,
        prix_Controller.text,
        date_Controller.text,
        context);
  }

  void getDemandeData() {
    jobDataInstance.getDemandeByid(widget.jobId).then((jobData1) {
      setState(() {
        jobTitle = jobData1['titre'];
        jobDescription = jobData1['description'];
        status = jobData1['status'];
        locationCompany = jobData1['ville'];
        postedDateTimeStamp = jobData1['postedDateTimeStamp'];
        deadlineDateTimeStamp = jobData1['deadlineDateTimeStamp'];
        deadlineDate = jobData1['deadlineDate'];
        userId = jobData1['userId'];
        imageUrls = List<String>.from(jobData1['imageUrls'] ?? []);
        var postDate = postedDateTimeStamp!.toDate();
        postedDate = '${postDate.year}-${postDate.month}-${postDate.day}';
        var date = deadlineDateTimeStamp!.toDate();
        isDeadlineAvailable = date.isAfter(DateTime.now());
      });
    });
  }

  UserData userDataInstance = UserData();

  void getMyData() async {
    userDataInstance.getUserById(curr).then((usertable) {
      setState(() {
        myName = usertable['name'];
        image = usertable['imageUrl'];
      });
    });
  }

  Future<void> getDataClient() async {
    userDataInstance.getUserById(widget.userId).then((usertable) {
      setState(() {
        authorName = usertable['name'];
        userImageUrl = usertable['imageUrl'];
        emailCompany = usertable['email'];
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDemandeData();
    getMyData();
    getDataClient();
  }

  Widget dividerWidget() {
    return Column(
      children: const [
        SizedBox(
          height: 10,
        ),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  applyForJob() {
    final Uri params = Uri(
      scheme: 'mailto',
      path: emailCompany,
      query:
          'subject=Applying for $jobTitle&body=Hello, Please attach resume CV file',
    );
    final url = params.toString();
    launchUrlString(url);
    addNewApplicant();
  }

  void addNewApplicant() async {
    var docRef = FirebaseFirestore.instance
        .collection('demandeTravail')
        .doc(widget.jobId);

    docRef.update({
      'applicants': applicants + 1,
    });
    Navigator.pop(context);
  }

  _pickDateDialog() async {
    picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        date_Controller.text =
            '${picked!.year}- ${picked!.month} - ${picked!.day}';
        deadLineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(
            picked!.microsecondsSinceEpoch);
      });
    }
  }

  void _showOffre() {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('offre de travail'),
            content: SizedBox(
              width: 120,
              height: 250,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: message_Controller,
                      decoration: const InputDecoration(
                        hintText: 'Entrez votre message ici',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un message';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: prix_Controller,
                      decoration: const InputDecoration(
                          hintText: 'Entrez votre prix ici',
                          suffixIcon: Icon(Icons.attach_money_rounded)),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un prix';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      readOnly: true,
                      onTap: () => _pickDateDialog(),
                      controller: date_Controller,
                      decoration: const InputDecoration(
                          hintText: 'Entrez votre date ici',
                          prefixIcon: Icon(Icons.date_range)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une date';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
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
                onPressed: () {
                  if (_formKey.currentState!.validate) {
                    _uploadOffre();

                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: Color.fromRGBO(255, 236, 239, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(55, 41, 72, 1),
          leading: IconButton(
            icon: const Icon(
              Icons.close,
              size: 40,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => jobScreen(),
                  ));
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black45,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            jobTitle == null ? '' : jobTitle!,
                            maxLines: 3,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (userId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfileSceen(
                                        userId: widget.uploadedBy,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.grey,
                                  ),
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      userImageUrl == null
                                          ? 'https://media.istockphoto.com/id/1209654046/vector/user-avatar-profile-icon-black-vector-illustration.jpg?s=612x612&w=0&k=20&c=EOYXACjtZmZQ5IsZ0UUp1iNmZ9q2xl1BD1VvN6tZ2UI='
                                          : userImageUrl!,
                                    ),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authorName == null ? '' : authorName!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    locationCompany == null
                                        ? ''
                                        : locationCompany!,
                                    style: const TextStyle(color: Colors.grey),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        FirebaseAuth.instance.currentUser!.uid !=
                                widget.uploadedBy
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  dividerWidget(),
                                  const Text(
                                    'affichage',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                          onPressed: () {
                                            User? user = _auth.currentUser;
                                            final _uid = user!.uid;

                                            if (_uid == widget.uploadedBy) {
                                              try {
                                                jobDataInstance.updateStatus(
                                                    true, widget.jobId);
                                              } catch (error) {
                                                GlobalMethode.showErrorDialog(
                                                    error:
                                                        'Action cannot be performed' /* error.toString() */,
                                                    ctx: context);
                                              }
                                            } else {
                                              GlobalMethode.showErrorDialog(
                                                  error:
                                                      'You cannot perform this action',
                                                  ctx: context);
                                            }
                                          },
                                          child: const Text(
                                            'ON',
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.normal),
                                          )),
                                      Opacity(
                                        opacity: status == true ? 1 : 0,
                                        child: const Icon(
                                          Icons.check_box,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 40,
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            User? user = _auth.currentUser;
                                            final _uid = user!.uid;

                                            if (_uid == widget.uploadedBy) {
                                              try {
                                                jobDataInstance.updateStatus(
                                                    false, widget.jobId);
                                              } catch (error) {
                                                GlobalMethode.showErrorDialog(
                                                    error:
                                                        'Action cannot be performed' /* error.toString() */,
                                                    ctx: context);
                                              }
                                            } else {
                                              GlobalMethode.showErrorDialog(
                                                  error:
                                                      'You cannot perform this action',
                                                  ctx: context);
                                            }
                                          },
                                          child: const Text(
                                            'OF',
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.normal),
                                          )),
                                      Opacity(
                                        opacity: status == false ? 1 : 0,
                                        child: const Icon(
                                          Icons.check_box,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                        dividerWidget(),
                        const Text(
                          'Description',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          jobDescription == null ? '' : jobDescription!,
                          textAlign: TextAlign.justify,
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        dividerWidget(),
                        imageUrls.isNotEmpty
                            ? Container(
                                height: 140,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: imageUrls.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ImageZoom(
                                                  imageUrl: imageUrls[index]),
                                            ),
                                          );
                                        },
                                        child: Image.network(
                                          imageUrls[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Text("")
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /*     const SizedBox(
                          height: 10,
                        ), */
                        Center(
                          child: Text(
                            isDeadlineAvailable
                                ? 'Actively Recruiting, Send Offre'
                                : 'deadLine Passed Away',
                            style: TextStyle(
                                color: isDeadlineAvailable
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.normal,
                                fontSize: 16),
                          ),
                        ),
                        isDeadlineAvailable &&
                                FirebaseAuth.instance.currentUser!.uid !=
                                    widget.uploadedBy
                            ? Center(
                                child: MaterialButton(
                                  onPressed: () {
                                    _showOffre();
                                  },
                                  color: const Color.fromRGBO(55, 41, 72, 1),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: Text(
                                      'Déposer offre',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                              )
                            : dividerWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Upload on:',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            Text(
                              postedDate == null ? '' : postedDate!,
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'DeadLine date :',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            Text(
                              deadlineDate == null ? '' : deadlineDate!,
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            )
                          ],
                        ),
                        dividerWidget(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(
                            milliseconds: 500,
                          ),
                          child: _isCommenting
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      flex: 3,
                                      //the commenter and what u want to write in commenter the color of the text etc...
                                      child: TextField(
                                        controller: _commentController,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        maxLength: 200,
                                        keyboardType: TextInputType.text,
                                        //u cannot write more than 6 line in comment
                                        maxLines: 6,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                        child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: MaterialButton(
                                            onPressed: () async {
                                              commentDataInstance
                                                  .ajouterCommentaire(
                                                      _commentController.text,
                                                      widget.jobId,
                                                      myName,
                                                      image,
                                                      context);
                                              _commentController.clear();

                                              setState(() {
                                                showComment = true;
                                              });
                                            },
                                            color: const Color.fromRGBO(
                                                55, 41, 72, 1),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'POST',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _isCommenting = !_isCommenting;
                                              showComment = false;
                                            });
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    ))
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isCommenting = !_isCommenting;
                                            // showComment = false;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.add_comment,
                                          color: Color.fromRGBO(55, 41, 72, 1),
                                          size: 40,
                                        )),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            // _isCommenting = !_isCommenting;
                                            showComment = true;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.arrow_drop_down_circle,
                                          color: Color.fromRGBO(55, 41, 72, 1),
                                          size: 40,
                                        )),
                                  ],
                                ),
                        ),
                        showComment == false
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: FutureBuilder<List<Object?>>(
                                  future: commentDataInstance
                                      .getJobComments(widget.jobId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else {
                                      if (snapshot.data == null ||
                                          snapshot.data!.isEmpty) {
                                        return const Center(
                                          child: Text('no comments'),
                                        );
                                      }
                                    }
                                    return ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        Map<String, dynamic> comment =
                                            snapshot.data![index]
                                                as Map<String, dynamic>;
                                        return CommentWidget(
                                          jobId: widget.jobId,
                                          uplaodedBy: widget.uploadedBy,
                                          commentId:
                                              comment['commentId'] as String,
                                          commenterId:
                                              comment['userId'] as String,
                                          commenterName:
                                              comment['name'] as String,
                                          commentBody:
                                              comment['commentBody'] as String,
                                          commenterImageUrl:
                                              comment['userImageUrl'] as String,
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return const Divider(
                                          thickness: 1,
                                          color: Colors.grey,
                                        );
                                      },
                                      itemCount: snapshot.data!.length,
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ImageZoom extends StatelessWidget {
  final String imageUrl;

  const ImageZoom({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(55, 41, 72, 1),
        title: const Text('Zoomable Image'),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
        ),
      ),
    );
  }
}
