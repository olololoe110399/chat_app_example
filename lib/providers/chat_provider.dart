import 'package:chat_app/constants/firestore_constants.dart';
import 'package:chat_app/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  ChatProvider({
    required this.firebaseStorage,
    required this.firebaseFirestore,
  });

  Stream<QuerySnapshot> getChatMessage(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  void sendChatMessage({
    required String content,
    required int type,
    required String groupChatId,
    required String currentUserId,
    required String peerId,
  }) {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    ChatMessages chatMessages = ChatMessages(
      idFrom: currentUserId,
      idTo: peerId,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
    );

    firebaseFirestore.runTransaction(
      (transaction) async => transaction.set(
        documentReference,
        chatMessages.toJson(),
      ),
    );
  }
}

enum MessageType { text, image, sticker }
