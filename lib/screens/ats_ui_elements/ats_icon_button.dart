import 'package:flutter/material.dart';

class atsIconButton extends StatelessWidget {
  atsIconButton(
      {super.key,
      required this.icon,
      required this.onPressed,
      this.size = 50,
      this.backgroundColor = null,
      this.foregroundColor = null});

  final Icon icon;
  final Function? onPressed;
  final double size;

  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onPressed as void Function()?,
        icon: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
              color: backgroundColor ??
                  Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(50)),
          child: Icon(
            size: size * 0.5,
            icon.icon,
            color: foregroundColor ??
                Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ));
  }
}
