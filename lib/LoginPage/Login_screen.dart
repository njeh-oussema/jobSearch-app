// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/SignUpPage/Sign_Up_Screen.dart';
import 'package:frontend/Data/userData.dart';
import 'package:frontend/services/global_methos.dart';

import '../ForgetPassword/forget_password_screen.dart';

class Login extends StatefulWidget {
  // const MyWidget({super.key});

  @override
  State<Login> createState() => _LogintState();
}

class _LogintState extends State<Login> with TickerProviderStateMixin {
  // late Animation<double> _animation;
  // late AnimationController _animationController;

  final TextEditingController _emailTextController =
      TextEditingController(text: '');

  final TextEditingController _passTextController =
      TextEditingController(text: '');

  final FocusNode _passFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscureText = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _loginFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // _animationController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }

  void LoginForm() {
    UserData userData = UserData();
    final isValid = _loginFormKey.currentState!.validate;
    if (isValid) {
      userData.Login1(_passTextController, _emailTextController, context);
    }
  }

  void _submitFormOnLogin() async {
    final isValid = _loginFormKey.currentState!.validate;
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      try {
        final email = _emailTextController.text.trim().toLowerCase();
        final password = _passTextController.text.trim();

        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        if (userSnapshot.docs.isEmpty) {
          GlobalMethode.showErrorDialog(
              error: 'Wrong email or password', ctx: context);
          setState(() {
            _isLoading = false;
          });
          return;
        }
        await _auth.signInWithEmailAndPassword(
            email: _emailTextController.text.trim().toLowerCase(),
            password: _passTextController.text.trim());
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      } catch (error) {
        GlobalMethode.showErrorDialog(
            error: 'Wrong email or password', ctx: context);
        setState(() {
          _isLoading = false;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          color: const Color.fromRGBO(255, 236, 239, 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 80, right: 80),
                  child: Image.asset('assets/images/logo2.png'),
                ),
                const SizedBox(
                  height: 15,
                ),
                Form(
                  key: _loginFormKey,
                  child: Column(children: [
                    emailText(
                        passFocusNode: _passFocusNode,
                        emailTextController: _emailTextController),
                    const SizedBox(
                      height: 15,
                    ),

                    TextFormField(
                      textInputAction: TextInputAction.next,
                      focusNode: _passFocusNode,
                      keyboardType: TextInputType.visiblePassword,
                      controller: _passTextController,
                      obscureText: !_obscureText, //change it dynamically
                      validator: (value) {
                        if (value!.isEmpty || value.length < 7) {
                          return 'please verify your password';
                        } else {
                          return null;
                        }
                      },
                      style: const TextStyle(color: Colors.black),
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
                              color: Colors.black,
                            ),
                          ),
                          hintText: 'Password',
                          hintStyle: const TextStyle(color: Colors.black),
                          enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          errorBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red))),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // Alignment:Alignment.bottomRight
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgetPassword()));
                        },
                        child: const Text(
                          'Forget Password ?',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MaterialButton(
                      // onPressed: _submitFormOnLogin,
                      onPressed: LoginForm,
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
                              'login',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
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
                            text: 'Do you not have an account?',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const TextSpan(text: '   '),
                        TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUp())),
                            text: 'SignUp',
                            style: const TextStyle(
                                color: Colors.cyan,
                                fontWeight: FontWeight.bold,
                                fontSize: 16))
                      ])),
                    )
                  ]),
                )
              ],
            ),
          ),
        )
      ]),
    );
  }
}

class emailText extends StatelessWidget {
  emailText({
    Key? key,
    required FocusNode passFocusNode,
    required TextEditingController emailTextController,
  })  : _passFocusNode = passFocusNode,
        _emailTextController = emailTextController,
        super(key: key);

  final FocusNode _passFocusNode;
  final TextEditingController _emailTextController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      onEditingComplete: () =>
          FocusScope.of(context).requestFocus(_passFocusNode),
      keyboardType: TextInputType.emailAddress,
      controller: _emailTextController,
      validator: (value) {
        if (value!.isEmpty || !value.contains('@')) {
          return 'please enter a valid email Adress';
        } else {
          return null;
        }
      },
      style: const TextStyle(color: Colors.black),
      decoration: const InputDecoration(
          hintText: 'Email',
          hintStyle: TextStyle(color: Colors.black),
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          focusedBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          errorBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.red))),
    );
  }
}
