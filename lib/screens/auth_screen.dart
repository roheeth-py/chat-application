import 'dart:io';

import 'package:chatapp/widgets/user_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  var _isLogin = true;
  File? _selectedImage;
  bool isAuth = false;
  final _enteredEmail = TextEditingController();
  final _enteredPassword = TextEditingController();
  final _enteredUserName = TextEditingController();

  Future<void> saveState() async {
    setState(() {
      isAuth = true;
    });
    if (!formKey.currentState!.validate() ||
        _selectedImage == null && !_isLogin) {
      setState(() {
        isAuth = false;
      });
      if (!_isLogin) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Missing Profile Details",
              style: TextStyle(color: Color(0xFFD01737)),
            ),
            backgroundColor: Colors.white,
          ),
        );
      }
      await Future.delayed(const Duration(seconds: 5), () {
        return formKey.currentState!.reset();
      });
      return;
    }
    formKey.currentState!.save();

    if (_isLogin) {
      try {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail.text, password: _enteredPassword.text);
        print(userCredentials);
        setState(() {
          isAuth = false;
        });
      } on FirebaseAuthException catch (error) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? "Authentication Failed"),
          ),
        );
        setState(() {
          isAuth = false;
        });
      }
    } else {
      try {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail.text, password: _enteredPassword.text);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_image")
            .child("${userCredentials.user!.uid}.jpg");
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        FirebaseFirestore.instance
            .collection("users")
            .doc(userCredentials.user!.uid)
            .set({
          "username": _enteredUserName.text,
          "email": _enteredEmail.text,
          "image_url": imageUrl
        });
        setState(() {
          isAuth = false;
        });
      } on FirebaseAuthException catch (error) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? "Authentication Failed"),
          ),
        );
        setState(() {
          isAuth = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _enteredEmail;
    _enteredPassword;
    _enteredUserName;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: 30,
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: Image.asset(
                    "lib/asset/chat.png",
                    width: 200,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              if (!_isLogin)
                                UserImage(
                                  imageFunc: (pickedImage) {
                                    _selectedImage = pickedImage;
                                  },
                                ),
                              if (!_isLogin)
                                TextFormField(
                                  controller: _enteredUserName,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(30),
                                      ),
                                    ),
                                    labelText: "User Name",
                                    prefixIcon: Icon(Icons.people),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  validator: (state) {
                                    if (state!.trim().isEmpty) {
                                      return "Invalid username";
                                    }
                                    return null;
                                  },
                                ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: _enteredEmail,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                  ),
                                  labelText: "Email ID",
                                  prefixIcon: Icon(Icons.mail_outline),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                validator: (state) {
                                  if (state!.trim().isEmpty ||
                                      !state.contains("@")) {
                                    return "Invalid Email";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              TextFormField(
                                controller: _enteredPassword,
                                validator: (state) {
                                  if (state!.trim().isEmpty ||
                                      state.length < 7) {
                                    return "Enter Password";
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                  ),
                                  labelText: "Password",
                                  prefixIcon: Icon(Icons.password_outlined),
                                ),
                                obscureText: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isAuth) const CircularProgressIndicator(),
                      if (!isAuth)
                        ElevatedButton(
                          onPressed: () {
                            saveState();
                          },
                          child: Text(
                            (_isLogin) ? "Login" : "Sign Up",
                          ),
                        ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          (_isLogin)
                              ? "Create Account"
                              : "I Already have an account",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
