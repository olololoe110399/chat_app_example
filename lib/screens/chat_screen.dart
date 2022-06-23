import 'dart:io';

import 'package:chat_app/constants/text_field_constants.dart';
import 'package:chat_app/models/chat_message.dart';
import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/providers/chat_provider.dart';
import 'package:chat_app/utillities/keyboard_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  const ChatScreen({
    Key? key,
    required this.peerId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatProvider chatProvider;
  late AuthProvider authProvider;
  late String currentUserId;
  late TextEditingController textEditingController;
  String groupChatId = "";
  bool loading = false;

  @override
  void initState() {
    chatProvider = context.read<ChatProvider>();
    authProvider = context.read<AuthProvider>();
    textEditingController = TextEditingController();
    if (authProvider.getFirebaseUserId?.isNotEmpty == true) {
      currentUserId = authProvider.getFirebaseUserId!;
    }
    if (currentUserId.compareTo(widget.peerId) > 0) {
      groupChatId = '$currentUserId - ${widget.peerId}';
    } else {
      groupChatId = '${widget.peerId} - $currentUserId';
    }
    super.initState();
  }

  void onSendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendChatMessage(
          content: content,
          type: type,
          groupChatId: groupChatId,
          currentUserId: currentUserId,
          peerId: widget.peerId);
    } else {
      Fluttertoast.showToast(
        msg: "Nothing to send",
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void _openLoadingDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      context: context,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Chat Page"),
          actions: [
            IconButton(
              onPressed: () {
                // call phone
              },
              icon: const Icon(Icons.phone),
            )
          ],
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                _buildListMessage(),
                _buildMessageInput(),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () => _onBackButton(context),
    );
  }

  Future<bool> _onBackButton(context) async {
    Navigator.pop(context);
    return true;
  }

  Widget _buildListMessage() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (KeyboardUtils.isKeyboardShowing()) {
            KeyboardUtils.closeKeyboard(context);
          }
        },
        child: StreamBuilder<QuerySnapshot>(
            stream: chatProvider.getChatMessage(groupChatId, 20),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                final listMessage = snapshot.data!.docs;
                if (listMessage.isNotEmpty) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: listMessage.length,
                    itemBuilder: (_, index) =>
                        _buildItem(index, listMessage[index]),
                    separatorBuilder: (_, index) => const SizedBox(
                      height: 10,
                    ),
                  );
                } else {
                  return const Center(
                    child: Text('No messages...'),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                );
              }
            }),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      height: 70,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              onPressed: () => getImage(context),
              icon: const Icon(
                Icons.camera_alt,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextField(
              controller: textEditingController,
              decoration: kTextInputDecoration,
              textInputAction: TextInputAction.send,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (value) {
                onSendMessage(value, MessageType.text.index);
              },
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              onPressed: () => onSendMessage(
                textEditingController.text,
                MessageType.text.index,
              ),
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(int index, DocumentSnapshot? documentSnapshot) {
    if (documentSnapshot != null) {
      final chatMessages = ChatMessages.fromDocument(documentSnapshot);
      final bool isUserMe = chatMessages.idFrom == currentUserId;
      return Column(
        children: [
          Row(
            mainAxisAlignment:
                isUserMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              _buildMessage(chatMessages, isUserMe),
            ],
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildMessage(ChatMessages chatMessages, bool isUserMe) {
    if (chatMessages.type == MessageType.text.index) {
      return _buildMessageBubble(
        chatContent: chatMessages.content,
        color: isUserMe ? Colors.black : Colors.red,
        textColor: Colors.white,
        margin: const EdgeInsets.all(0),
      );
    } else if (chatMessages.type == MessageType.image.index) {
      return OutlinedButton(
        onPressed: () {},
        child: Image.network(
          chatMessages.content,
          width: 200,
          height: 200,
          fit: BoxFit.fitHeight,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildMessageBubble({
    required String chatContent,
    required EdgeInsetsGeometry? margin,
    Color? textColor,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: margin,
      width: 200,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        chatContent,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
        ),
      ),
    );
  }

  void getImage(context) async {
    final imagePicker = ImagePicker();
    XFile? pickerFile;
    pickerFile = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickerFile != null) {
      final imageFile = File(pickerFile.path);
      _openLoadingDialog(context);
      uploadImageFile(imageFile, context);
    }
  }

  void uploadImageFile(File imageFile, context) {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    chatProvider
        .uploadImageFile(imageFile, fileName)
        .then((snapshot) => snapshot.ref.getDownloadURL())
        .then((imageUrl) {
      _onBackButton(context);
      onSendMessage(imageUrl, MessageType.image.index);
    }).catchError((error) {
      print(error);
      _onBackButton(context);
      Fluttertoast.showToast(msg: error.message ?? error.toString());
    });
  }
}
