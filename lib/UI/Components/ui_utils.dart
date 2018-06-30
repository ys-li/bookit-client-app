import 'package:flutter/material.dart';

Widget addPadding(Widget widget, EdgeInsets insets){
  return new Padding(
    child: widget,
    padding: insets,
  );
}