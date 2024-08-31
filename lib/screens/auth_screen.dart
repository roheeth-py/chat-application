import 'package:firebase_auth/firebase_auth.dart';
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
  // final _enteredEmail = TextEditingController();
  // final _enteredPassword = TextEditingController();

  Future<void> saveState() async {
    if (!formKey.currentState!.validate()) {
      await Future.delayed(const Duration(seconds: 5), () {
        return formKey.currentState!.reset();
      });
    }
    formKey.currentState!.save();

    if (_isLogin) {
      try {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: "test@gmail.com", password: "1qaz!QAZ");
        print(userCredentials);
      } on FirebaseAuthException catch (error) {
        if(!context.mounted){
          return ;
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(

            content: Text(error.message ?? "Authentication Failed"),
          ),
        );
      }
    } else {
      try {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: "test@gmail.com", password: "1qaz!QAZ");
        print(userCredentials);
      } on FirebaseAuthException catch (error) {
        if(!context.mounted){
          return ;
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? "Authentication Failed"),
          ),
        );
      }
    }
  }

  // @override
  // void dispose() {
  //   _enteredEmail;
  //   _enteredPassword;
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                        TextFormField(
                          // controller: _enteredEmail,
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
                            if (state!.trim().isEmpty || !state.contains("@")) {
                              return "Invalid Email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        TextFormField(
                          // controller: _enteredPassword,
                          validator: (state) {
                            if (state!.trim().isEmpty || state.length<7) {
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
                ElevatedButton(
                  onPressed: ()  {
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
                    (_isLogin) ? "Create Account" : "I Already have an account",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
