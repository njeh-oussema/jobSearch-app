import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/myProfile/update_profile.dart';
import 'package:frontend/services/global_methos.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

void showErrorDialog({required String error, required BuildContext ctx}) {
  showDialog(
      context: ctx,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.logout,
                  color: Colors.grey,
                  size: 35,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Error Occured',
                ),
              )
            ],
          ),
          content: Text(
            error,
            style: const TextStyle(
                color: Colors.black, fontSize: 20, fontStyle: FontStyle.italic),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  if (_auth != null && _auth.currentUser != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                updateProfile(userId: _auth.currentUser!.uid)));
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.red),
                ))
          ],
        );
      });
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;
Future<void> updatePassword(String oldPassword, String newPassword) async {
  try {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;

    // Verify the old password
    final credential = EmailAuthProvider.credential(
      email: user!.email!,
      password: oldPassword,
    );
    //to refresh daata to know the last password that you use
    await user.reauthenticateWithCredential(credential);
    // Update the password
    await user.updatePassword(newPassword);
  } catch (e) {}
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController oldPassword = TextEditingController(text: '');
  final TextEditingController newPassword = TextEditingController(text: '');
  // ignore: non_constant_identifier_names
  final TextEditingController ConfirmNewPassword =
      TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    Future<bool> isOldPasswordCorrect(String oldPassword) async {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? currentUser = auth.currentUser;

      if (currentUser == null) {
        return false;
      }

      try {
        var credential = EmailAuthProvider.credential(
            email: currentUser.email!, password: oldPassword);
        await currentUser.reauthenticateWithCredential(credential);
        return true; // If reauthentication succeeds, the old password was correct.
      } catch (e) {
        return false; // If any error occurs during reauthentication, return false.
      }
    }

    Future<bool> changePassword(
        {required oldPass,
        required newPass,
        required BuildContext context}) async {
      final FirebaseAuth auth = FirebaseAuth.instance;
      var currentUser = auth.currentUser;

      if (currentUser == null) {
        return false;
      }

      bool isCorrect = await isOldPasswordCorrect(oldPass);
      if (!isCorrect) {
        return false;
      }

      try {
        return true;
      } catch (e) {
        showErrorDialog(error: "An unknown error occurred", ctx: context);
        return false;
      }
    }

    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 236, 239, 1),
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: const Color.fromRGBO(55, 41, 72, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: oldPassword,
                decoration: const InputDecoration(labelText: 'Old Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your old password.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: newPassword,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: ConfirmNewPassword,
                decoration:
                    const InputDecoration(labelText: 'Confirm New Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password.';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate) {
                    _formKey.currentState!.save();
                    bool changeSuccessful = await changePassword(
                        oldPass: oldPassword.text.trim(),
                        newPass: newPassword.text.trim(),
                        context: context);
                    if (ConfirmNewPassword.text.trim() !=
                        newPassword.text.trim()) {
                      GlobalMethode.showErrorDialog(
                          error: "verif your new password", ctx: context);
                    } else if (changeSuccessful) {
                      GlobalMethode.showErrorDialog(
                          error: "your password is updated", ctx: context);
                    }
                    if (changeSuccessful == false) {
                      GlobalMethode.showErrorDialog(
                          error: "password doesn't change", ctx: context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(55, 41, 72, 1),
                    side: BorderSide.none,
                    shape: const StadiumBorder()),
                child: const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
