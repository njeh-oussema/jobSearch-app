import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

class secteurData {
  Stream<QuerySnapshot> getSecteur() {
    return FirebaseFirestore.instance.collection('secteur').snapshots();
  }

  Future<bool> isSecteurExist(String secteurName) async {
    final result = await FirebaseFirestore.instance
        .collection('secteur')
        .where('name', isEqualTo: secteurName)
        .get();

    if (result.docs.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<void> addSecteur(newSecteur) async {
    final sectorId = const Uuid().v4();
    if (await isSecteurExist(newSecteur)) {
      await Fluttertoast.showToast(
        msg: 'le secteur est existe deja',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.grey,
        fontSize: 18.0,
      );
      newSecteur == null;
    } else {
      await FirebaseFirestore.instance.collection('secteur').doc(sectorId).set({
        'name': newSecteur,
      });
    }
  }
}
