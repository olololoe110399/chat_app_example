import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FirebaseMessagingHelper {
  final _messaging = FirebaseMessaging.instance;

  static final FirebaseMessagingHelper _singleton = FirebaseMessagingHelper();

  static FirebaseMessagingHelper get instance => _singleton;

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;
  Future<RemoteMessage?> get getInitialMessage =>
      _messaging.getInitialMessage();
  Future<String?> get deviceToken => _messaging.getToken();
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    final connectivityResult = await Connectivity().checkConnectivity();
    if ([ConnectivityResult.mobile, ConnectivityResult.wifi]
        .contains(connectivityResult)) {
      deviceToken.then((value) {
        print("[FirebaseMessagingHelper] :deviceToken $value ");
      }).catchError((err) {
        print("[FirebaseMessagingHelper] :err $err ");
      });
    }
    await requestPermission();
  }

  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final NotificationSettings settings =
          await _messaging.requestPermission();
      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
        case AuthorizationStatus.provisional:
          return true;
        default:
          return false;
      }
    }
    return true;
  }

  Future _handleBackgroundMessage(RemoteMessage remoteMessage) async {
    // handle background
  }
}
