import 'package:chat_app/constants/firestore_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  final FirebaseFirestore firebaseFirestore;

  HomeProvider({
    required this.firebaseFirestore,
  });

  Stream<QuerySnapshot<Map<String, dynamic>>> getFirestoreData({
    required String collectionPath,
    int limit = 10,
    String? textSearch,
  }) {
    if (textSearch?.isNotEmpty == true) {
      return firebaseFirestore
          .collection(collectionPath)
          .limit(limit)
          .where(
            FirestoreConstants.displayName,
            isGreaterThanOrEqualTo: textSearch,
          )
          .snapshots();
    } else {
      return firebaseFirestore
          .collection(collectionPath)
          .limit(limit)
          .snapshots();
    }
  }
}
