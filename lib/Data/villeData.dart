import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

class villeData {
  Stream<QuerySnapshot> getVille() {
    return FirebaseFirestore.instance.collection('ville').snapshots();
  }

  Future<bool> isLocationExist(String locationName) async {
    final result = await FirebaseFirestore.instance
        .collection('ville')
        .where('name', isEqualTo: locationName)
        .get();

    if (result.docs.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<void> addLocation(newVille) async {
    // ignore: unrelated_type_equality_checks
    final sectorId = const Uuid().v4();
    if (await isLocationExist(newVille)) {
      await Fluttertoast.showToast(
        msg: 'ville existe deja',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.grey,
        fontSize: 18.0,
      );
    } else {
      await FirebaseFirestore.instance.collection('ville').doc(sectorId).set({
        // 'id': sectorId,
        'name': newVille,
      });
    }
  }
}
