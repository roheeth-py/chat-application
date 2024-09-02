import 'package:chatapp/widgets/chat_messages.dart';
import 'package:chatapp/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "You nd Me",
            style: GoogleFonts.greatVibes(
              fontWeight: FontWeight.w500,
              fontSize: 24,
            ),
          ),
          forceMaterialTransparency: true,
          elevation: 0,
          leading: IconButton(
            onPressed: signOut,
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert_outlined),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(child: ChatMessages()),
            NewMessage(),
          ],
        ));
  }
}
