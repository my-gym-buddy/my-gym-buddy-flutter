import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class atsTextField extends StatefulWidget {
  atsTextField(
      {super.key,
      required this.textEditingController,
      required this.labelText,
      this.onEditingComplete});

  final TextEditingController textEditingController;
  final String labelText;

  Function? onEditingComplete;

  @override
  State<atsTextField> createState() => _atsTextFieldState();
}

class _atsTextFieldState extends State<atsTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: widget.textEditingController,
        onEditingComplete: widget.onEditingComplete as void Function()?,
        decoration: InputDecoration(
          floatingLabelAlignment: FloatingLabelAlignment.center,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          labelText: widget.labelText,
        ));
  }
}
