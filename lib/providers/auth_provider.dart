import 'package:chat_app/constants/all_constants.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateCanceled,
}

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseStorage;
  final SharedPreferences sharedPreferences;

  Status _status = Status.uninitialized;

  Status get status => _status;

  AuthProvider({
    required this.googleSignIn,
    required this.firebaseAuth,
    required this.firebaseStorage,
    required this.sharedPreferences,
  });

  String? get getFirebaseUserId =>
      sharedPreferences.getString(FirestoreConstants.id);

  Future<bool> isLogin() => googleSignIn.isSignedIn();

  Future<bool> handleGoogleSignIn() async {
    _status = Status.authenticating;
    notifyListeners();
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      User? firebaseUser =
          (await firebaseAuth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await firebaseStorage
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
            .get();

        final List<DocumentSnapshot> document = result.docs;
        if (document.isEmpty) {
          firebaseStorage
              .collection(FirestoreConstants.pathUserCollection)
              .doc(firebaseUser.uid)
              .set({
            FirestoreConstants.displayName: firebaseUser.displayName,
            FirestoreConstants.photoUrl: firebaseUser.photoURL,
            FirestoreConstants.id: firebaseUser.uid,
            "createdAt: ": DateTime.now().millisecondsSinceEpoch.toString(),
            FirestoreConstants.chattingWith: null,
          });

          User? currentUser = firebaseUser;
          await sharedPreferences.setString(
              FirestoreConstants.id, currentUser.uid);
          await sharedPreferences.setString(
              FirestoreConstants.displayName, currentUser.displayName ?? "");
          await sharedPreferences.setString(
              FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
          await sharedPreferences.setString(
              FirestoreConstants.phoneNumber, currentUser.phoneNumber ?? "");
        } else {
          DocumentSnapshot documentSnapshot = document[0];
          ChatUser userChat = ChatUser.fromDocument(documentSnapshot);
          await sharedPreferences.setString(FirestoreConstants.id, userChat.id);
          await sharedPreferences.setString(
              FirestoreConstants.displayName, userChat.displayName);
          await sharedPreferences.setString(
              FirestoreConstants.aboutMe, userChat.aboutMe);
          await sharedPreferences.setString(
              FirestoreConstants.phoneNumber, userChat.phoneNumber);
          await sharedPreferences.setString(
              FirestoreConstants.countryCode, userChat.countryCode);
        }
        _status = Status.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    } else {
      _status = Status.authenticateCanceled;
      notifyListeners();
      return false;
    }
  }

  Future<void> googleSignOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }
}
