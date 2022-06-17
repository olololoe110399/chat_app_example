import 'package:flutter/material.dart';

const kTextInputDecoration = InputDecoration(
  labelStyle: TextStyle(
    color: Colors.blue,
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blue, width: 1.5),
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blue, width: 1.5),
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 1.5),
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 1.5),
    borderRadius: BorderRadius.all(
      Radius.circular(10),
    ),
  ),
  border: OutlineInputBorder(),
  hintText: 'Enter a search user',
);
