import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/hepler/firebase_messaging_helper.dart';
import 'package:chat_app/hepler/local_push_notification_help.dart';
import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/providers/chat_provider.dart';
import 'package:chat_app/providers/home_provider.dart';
import 'package:chat_app/screens/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessagingHelper.instance.init();
  await LocalPushNotificationHelper.instance.init();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(sharedPreferences: prefs));
}

class MyApp extends StatefulWidget {
  final SharedPreferences sharedPreferences;

  const MyApp({Key? key, required this.sharedPreferences}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  @override
  void initState() {
    // FirebaseMessagingHelper
    FirebaseMessagingHelper.instance.onMessage.listen(
      LocalPushNotificationHelper.instance.notify,
    );
    FirebaseMessagingHelper.instance.onMessageOpenedApp.listen((event) {
      LocalPushNotificationHelper.instance
          .handleSelectNotificationMap(event.data);
    });
    FirebaseMessagingHelper.instance.getInitialMessage.then((value) {
      if (value != null) {
        LocalPushNotificationHelper.instance
            .handleSelectNotificationMap(value.data);
      }
    });
    // LocalPushNotificationHelper
    LocalPushNotificationHelper.instance.selectNotificationSubject.listen(
      LocalPushNotificationHelper.instance.handleSelectNotificationPayload,
    );
    LocalPushNotificationHelper.instance.details.then((value) {
      if (value != null) {
        LocalPushNotificationHelper.instance
            .handleSelectNotificationPayload(value.payload);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            googleSignIn: GoogleSignIn(),
            firebaseAuth: FirebaseAuth.instance,
            firebaseStorage: firebaseFirestore,
            sharedPreferences: widget.sharedPreferences,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            firebaseFirestore: firebaseFirestore,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            firebaseStorage: firebaseStorage,
            firebaseFirestore: firebaseFirestore,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Chat Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
