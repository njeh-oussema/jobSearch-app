import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:frontend/LoginPage/Login_screen.dart';
import '../services/global_methos.dart';

class UserData {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void submitFormOnSignUp1(
      String collectionName,
      TextEditingController password,
      TextEditingController emailController,
      TextEditingController adresseController,
      TextEditingController secteurCategory,
      TextEditingController fullNameController,
      TextEditingController phoneNumberController,
      File? imageFile,
      BuildContext context) async {
    try {
      final email = emailController.text.trim().toLowerCase();
      final signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (signInMethods.isNotEmpty) {
        GlobalMethode.showErrorDialog(
            error: "email existe déja !!", ctx: context);
        return;
      }
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password.text.trim());
      final User? user = _auth.currentUser;
      final uid = user!.uid;
      final ref =
          FirebaseStorage.instance.ref().child('userImage').child(uid + '.jpg');
      await ref.putFile(imageFile!);
      final imageurl = await ref.getDownloadURL();
      FirebaseFirestore.instance.collection(collectionName).doc(uid).set({
        'createdAt': Timestamp.now(),
        'email': email,
        'id': uid,
        'location': adresseController.text,
        'name': fullNameController.text,
        'phoneNumber': phoneNumberController.text,
        'secteur': secteurCategory.text,
        'userImage': imageurl,
        'ratings': []
      });
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => Login(),
        ),
      );
    } catch (error) {
      GlobalMethode.showErrorDialog(error: "An error occurred", ctx: context);
    }
  }

  void Login1(TextEditingController password1, TextEditingController email1,
      BuildContext context) async {
    try {
      final email = email1.text.trim().toLowerCase();
      final password = password1.text.trim();

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (userSnapshot.docs.isEmpty) {
        GlobalMethode.showErrorDialog(
            error: 'Wrong email or password', ctx: context);
        return;
      }
      await _auth.signInWithEmailAndPassword(
          email: email1.text.trim().toLowerCase(),
          password: password1.text.trim());
      // ignore: use_build_context_synchronously
      Navigator.canPop(context) ? Navigator.pop(context) : null;
    } catch (error) {
      GlobalMethode.showErrorDialog(
          error: 'Wrong email or password', ctx: context);
    }
  }

  Stream<QuerySnapshot> getUserBySecteur(String secteur) {
    var userBySecteur = FirebaseFirestore.instance
        .collection('users')
        .where('secteur', isEqualTo: secteur)
        .snapshots();

    return userBySecteur;
  }

  Stream<QuerySnapshot> getUserByName(String secteur) {
    var userByName = FirebaseFirestore.instance
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: secteur)
        .where('name', isLessThan: '${secteur}z')
        .snapshots();

    return userByName;
  }

  Future<Map<String, dynamic>> getUserById(userId) async {
    Map<String, dynamic> usertable = {};

    final DocumentSnapshot userDatabase =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDatabase == null) {
      return usertable;
    }
    usertable = {
      'name': userDatabase.get('name'),
      'email': userDatabase.get('email'),
      'phoneNumber': userDatabase.get('phoneNumber'),
      'imageUrl': userDatabase.get('userImage'),
      'secteur': userDatabase.get('secteur'),
      'joinedAtTimeStamp': userDatabase.get('createdAt'),
      'ville': userDatabase.get('location')
    };
    return usertable;
  }

  Future<void> rateuser(double note, userId) async {
    final CollectionReference userRef =
        FirebaseFirestore.instance.collection('users');
    final DocumentSnapshot snapshot = await userRef.doc(userId).get();
    final List<dynamic> ratings = snapshot.get('ratings');
    int nbr = ratings.length;
    if (nbr > 0) {
      for (int i = 0; i < nbr; i++) {
        if (ratings[i]['ratedBy'] == _auth.currentUser!.uid) {
          var updatedRating = {
            'ratedBy': _auth.currentUser!.uid,
            'rating': note,
          };
          ratings[i] = updatedRating;
          userRef.doc(userId).update({
            'ratings': ratings,
          });
        } else {
          userRef.doc(userId).update({
            'ratings': FieldValue.arrayUnion([
              {
                'ratedBy': _auth.currentUser!.uid,
                'rating': note,
              }
            ])
          });
        }
      }
      ratings[0];
    } else {
      userRef.doc(userId).update({
        'ratings': FieldValue.arrayUnion([
          {
            'ratedBy': _auth.currentUser!.uid,
            'rating': note,
          }
        ])
      });
    }
  }

  String imageUrl = '';
  final FirebaseAuth _aut = FirebaseAuth.instance;

  void updateProfile(name, phone, ville, secteur, image, email) async {
    final User? user = _aut.currentUser;
    final _uid = user!.uid;
    if (image != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('userImage')
          .child(_uid + '.jpg');
      await ref.putFile(image!);
      imageUrl = await ref.getDownloadURL();
    }
    await FirebaseFirestore.instance.collection('users').doc(_uid).update({
      'name': name,
      'phoneNumber': phone,
      'location': ville,
      'secteur': secteur,
      'userImage': imageUrl,
      'email': email
    });
    await user.updateEmail(email);
  }
}
