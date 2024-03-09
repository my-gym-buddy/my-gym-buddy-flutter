import 'package:flutter/material.dart';

class atsIconButton extends StatelessWidget {
  atsIconButton(
      {super.key,
      required this.icon,
      required this.onPressed,
      this.size = 50,
      this.backgroundColor = null});

  final Icon icon;
  final Function? onPressed;
  final double size;

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onPressed as void Function()?,
        icon: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(50)),
          child: Icon(
            icon.icon,
            color: backgroundColor ??
                Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ));
  }
}
