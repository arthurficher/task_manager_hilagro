import 'package:flutter/material.dart';

class TitleTask extends StatelessWidget {
  const TitleTask({
    super.key,
    required this.text,
    this.color,
    this.fontSize,
  });
  
  final String text;
  final Color? color;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize ?? 24,
        fontWeight: FontWeight.bold,
        color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }
}
