import 'package:chat_app/constants/all_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class ChatUser extends Equatable {
  final String id;
  final String photoUrl;
  final String displayName;
  final String phoneNumber;
  final String countryCode;
  final String aboutMe;

  const ChatUser(
      {required this.id,
      required this.photoUrl,
      required this.displayName,
      required this.phoneNumber,
      required this.countryCode,
      required this.aboutMe});

  ChatUser copyWith({
    String? id,
    String? photoUrl,
    String? nickname,
    String? phoneNumber,
    String? countryCode,
    String? email,
  }) =>
      ChatUser(
          id: id ?? this.id,
          photoUrl: photoUrl ?? this.photoUrl,
          displayName: nickname ?? displayName,
          phoneNumber: phoneNumber ?? this.phoneNumber,
          countryCode: countryCode ?? this.countryCode,
          aboutMe: email ?? aboutMe);

  Map<String, dynamic> toJson() => {
        FirestoreConstants.displayName: displayName,
        FirestoreConstants.photoUrl: photoUrl,
        FirestoreConstants.phoneNumber: phoneNumber,
        FirestoreConstants.countryCode: countryCode,
        FirestoreConstants.aboutMe: aboutMe,
      };
  factory ChatUser.fromDocument(DocumentSnapshot snapshot) {
    String photoUrl = "";
    String nickname = "";
    String phoneNumber = "";
    String countryCode = "";
    String aboutMe = "";

    try {
      photoUrl = snapshot.get(FirestoreConstants.photoUrl);
      nickname = snapshot.get(FirestoreConstants.displayName);
      countryCode = snapshot.get(FirestoreConstants.countryCode);
      phoneNumber = snapshot.get(FirestoreConstants.phoneNumber);
      aboutMe = snapshot.get(FirestoreConstants.aboutMe);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return ChatUser(
        id: snapshot.id,
        photoUrl: photoUrl,
        displayName: nickname,
        phoneNumber: phoneNumber,
        countryCode: countryCode,
        aboutMe: aboutMe);
  }
  @override
  List<Object?> get props =>
      [id, photoUrl, displayName, phoneNumber, countryCode, aboutMe];
}
