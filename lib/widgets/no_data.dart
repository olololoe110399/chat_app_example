import 'package:flutter/material.dart';

class NoData extends StatelessWidget {
  final String? content;
  const NoData({Key? key, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(content ?? 'Không có dữ liệu...'),
    );
  }
}
