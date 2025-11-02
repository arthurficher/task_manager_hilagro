import 'package:flutter/material.dart';

class TitleTask extends StatelessWidget {
  const TitleTask({
    super.key,
    required this.text,
    this.color,
  });
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final size =
        MediaQuery.of(context).size;
    final height = size.height;

    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontSize: height * 0.019,
            fontWeight: FontWeight.w600,
            color: color
          ),
    );
  }
}
