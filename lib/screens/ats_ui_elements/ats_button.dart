import 'package:flutter/material.dart';

class atsButton extends StatelessWidget {
  const atsButton(
      {super.key,
      required this.child,
      required this.onPressed,
      this.backgroundColor});

  final Widget child;
  final Function? onPressed;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed as void Function()?,
        style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: backgroundColor ??
                Theme.of(context).colorScheme.primaryContainer),
        child: child);
  }
}
