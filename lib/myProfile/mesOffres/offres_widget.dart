import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/global_methos.dart';
import '../profilee_screeen.dart';

class offer_widget extends StatefulWidget {
  final String status;
  final String offerId;
  final String jobId;

  final String workerId;
  final String workerImage;
  final String jobname;
  final String message;
  final String prix;
  final String date;

  const offer_widget({
    required this.status,
    required this.offerId,
    required this.jobId,
    required this.workerId,
    required this.workerImage,
    required this.jobname,
    required this.prix,
    required this.message,
    required this.date,
  });

  @override
  State<offer_widget> createState() => _offer_widgetState();
}

String status = "waiting";

class _offer_widgetState extends State<offer_widget> {
  void getOfferStatus() async {
    DocumentSnapshot<Map<String, dynamic>> offerSnapshot =
        await FirebaseFirestore.instance
            .collection('offres')
            .doc(widget.offerId)
            .get();

    if (offerSnapshot.exists) {
      setState(() {
        status = offerSnapshot.data()!['status'];
      });
    }
  }

  void offeraccepted5() async {
    try {
      await FirebaseFirestore.instance
          .collection('offres')
          .doc(widget.offerId)
          .update({'status': "accepted"});
      print("d5alnaa lil 4eni");

      await FirebaseFirestore.instance
          .collection('demandeTravail')
          .doc(widget.jobId)
          .update({'recruitement': false});
    } catch (e) {
      GlobalMethode.showErrorDialog(error: e.toString(), ctx: context);
    }
  }

/*   void offeraccepted55() async {
    try {
      await FirebaseFirestore.instance
          .collection('offres')
          .doc(widget.offerId)
          .update({'status': "accepted"});
      print("Accepted offer: ${widget.offerId}");

      await FirebaseFirestore.instance
          .collection('demandeTravail')
          .doc(widget.jobId)
          .update({'status': false});

      final querySnapshot = await FirebaseFirestore.instance
          .collection('offres')
          .where('job_id', isEqualTo: widget.jobId)
          .get();

      for (final doc in querySnapshot.docs) {
        if (doc.id != widget.offerId) {
          await FirebaseFirestore.instance
              .collection('offres')
              .doc(doc.id)
              .update({'status': 'refused'});
          print("Refused offer: ${doc.id}");
        }
      }
    } catch (e) {
      GlobalMethode.showErrorDialog(error: e.toString(), ctx: context);
    }
  } */

  void offerRefused() async {
    try {
      await FirebaseFirestore.instance
          .collection('offres')
          .doc(widget.offerId)
          .update({'status': "refused"});
      // getOfferStatus();
    } catch (e) {
      GlobalMethode.showErrorDialog(error: e.toString(), ctx: context);
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white24,
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
          onTap: () {},
          onLongPress: () {},
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileSceen(userId: widget.workerId),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.only(right: 12),
                decoration: const BoxDecoration(
                    border: Border(right: BorderSide(width: 1))),
                child: Image.network(widget.workerImage),
              )),
          title: Text(widget.jobname,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              )),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(widget.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  )),
              const SizedBox(
                height: 8,
              ),
              Text(
                widget.prix + " " + "DT",
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                widget.date.toString(),
                style: const TextStyle(color: Colors.black45),
              ),
            ],
          ),
          trailing: widget.status == "waiting"
              ? Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        offeraccepted5();
                      },
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        offerRefused();
                      },
                      child: const Icon(
                        Icons.cancel,
                        color: Colors.red,
                      ),
                    )
                  ],
                )
              : widget.status == "refused"
                  ? Column(
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            offerRefused();
                          },
                          child: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                        )
                      ],
                    )
                  : Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            offeraccepted5();
                          },
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                      ],
                    )),
    );
  }
}
