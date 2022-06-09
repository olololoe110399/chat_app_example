import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  Widget _buildListMessage() {
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 16,
        ),
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (context, index) => _buildItem(),
        separatorBuilder: (_, index) => const SizedBox(
          height: 10,
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter a search user',
      ),
      onChanged: (value) {},
    );
  }

  Widget _buildItem() {
    return Container(
      height: 100,
      width: 100,
      color: Colors.red,
    );
  }
}
