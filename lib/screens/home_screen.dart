import 'package:chat_app/constants/all_constants.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/providers/home_provider.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/widgets/no_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:dartx/dartx.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String currentUserId;
  String _textSearch = "";

  @override
  void initState() {
    final auth = context.read<AuthProvider>();
    final homeProvider = context.read<HomeProvider>();
    if (auth.getFirebaseUserId?.isNotEmpty == true) {
      currentUserId = auth.getFirebaseUserId!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Chat App'),
        actions: [
          IconButton(
            onPressed: () async {
              await auth.googleSignOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            onPressed: () {
              // go to profile
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a search user',
                ),
                onChanged: (value) {
                  setState(() {
                    _textSearch = value;
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: homeProvider.getFirestoreData(
                  collectionPath: FirestoreConstants.pathUserCollection,
                  textSearch: _textSearch,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return NoData(
                      content: snapshot.error?.toString(),
                    );
                  }
                  if (snapshot.hasData) {
                    final length = snapshot.data?.docs.length ?? 0;
                    if (length > 0) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        shrinkWrap: true,
                        itemCount: length,
                        itemBuilder: (context, index) => _buildItem(
                          context: context,
                          data: snapshot.data?.docs.elementAtOrNull(index),
                        ),
                      );
                    } else {
                      return const NoData(
                        content: 'User not found',
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    required BuildContext context,
    DocumentSnapshot? data,
  }) {
    if (data != null) {
      ChatUser userChat = ChatUser.fromDocument(data);
      if (userChat.id == currentUserId) {
        return const SizedBox.shrink();
      } else {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChatScreen(),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCircleImage(userChat.photoUrl),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  userChat.displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildCircleImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: 50,
        height: 50,
        loadingBuilder: (
          BuildContext context,
          Widget widget,
          ImageChunkEvent? imageChunkEvent,
        ) {
          if (imageChunkEvent == null) {
            return widget;
          } else {
            return const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: Colors.amber,
              ),
            );
          }
        },
        errorBuilder: (
          BuildContext context,
          Object object,
          StackTrace? stackTrace,
        ) {
          return const Icon(
            Icons.account_circle,
            size: 50,
          );
        },
      ),
    );
  }
}
