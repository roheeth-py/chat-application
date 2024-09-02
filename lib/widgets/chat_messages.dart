import 'package:chatapp/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    var authUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy("time", descending: true)
          .snapshots(),
      builder: (ctx, chatSnap) {
        if (chatSnap.connectionState == ConnectionState.waiting ) {
          const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!chatSnap.hasData || chatSnap.data!.docs.isEmpty) {
          const Center(
            child: Text("Start Converstion"),
          );
        }

        if (!chatSnap.hasError) {
          const Center(
            child: Text("Failed to load data"),
          );
        }

        final data = chatSnap.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.only(left: 14, right: 13, bottom: 14),
          reverse: true,
          itemCount: data.length,
          itemBuilder: (ctx, item) {
            final chatMessage = data[item].data();
            final next = item + 1 < data.length ? data[item + 1].data() : null;
            final currentUser = chatMessage["uid"];
            final nextUser = next!=null? next["uid"]:null;
            final nextUserSame = currentUser == nextUser;
            if(nextUserSame){
              return MessageBubble.next(message: chatMessage["text"], isMe: authUser.uid==currentUser);
            }else{
              return MessageBubble.first(userImage: chatMessage["user_image"], username: chatMessage["user_id"], message: chatMessage["text"], isMe: authUser.uid==currentUser);
            }
          },
        );
      },
    );
  }
}
