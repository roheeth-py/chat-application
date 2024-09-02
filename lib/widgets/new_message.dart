import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final message = TextEditingController();

  Future<void> submit() async {
    final enterText = message.text;
    if (enterText.trim().isEmpty) {
      print("object");
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

    await FirebaseFirestore.instance.collection("chat").add({
      "text": enterText,
      "time":Timestamp.now(),
      "user_id": userData.data()!["username"],
      "user_image": userData.data()!["image_url"],
      "uid":user.uid,
    });

    message.clear();
  }

  @override
  void dispose() {
    message;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 5, bottom: 14,top: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: message,
              autocorrect: true,
              textCapitalization: TextCapitalization.sentences,
              enableSuggestions: true,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                hintText: "Message",
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(35),
                    borderSide: BorderSide(color: Colors.black38)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(35),
                    borderSide: BorderSide(color: Colors.black38)),
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF007AFF).withOpacity(0.8),
            ),
            child: IconButton(
              onPressed: submit,
              icon: Icon(
                Icons.send,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
