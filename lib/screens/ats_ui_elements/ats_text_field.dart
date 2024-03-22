import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AtsTextField extends StatefulWidget {
  AtsTextField(
      {Key? key,
      required this.labelText,
      this.textEditingController,
      this.onEditingComplete,
      this.keyboardType,
      this.enabled = true,
      this.onChanged,
      this.selectAllOnTap = false,
      this.minLines = 1,
      this.maxLines = 1});

  final TextEditingController? textEditingController;
  final String labelText;

  final TextInputType? keyboardType;

  final bool selectAllOnTap;

  final bool enabled;

  Function? onEditingComplete;
  Function? onChanged;

  final int minLines;
  final int maxLines;

  @override
  State<AtsTextField> createState() => _AtsTextFieldState();
}

class _AtsTextFieldState extends State<AtsTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      controller: widget.textEditingController,
      enabled: widget.enabled,
      onEditingComplete: widget.onEditingComplete as void Function()?,
      onChanged: (value) {
        if (widget.onChanged != null) {
          widget.textEditingController!.text = value;
          widget.onChanged!(value);
        }
      },
      onTap: () {
        if (widget.selectAllOnTap) {
          widget.textEditingController!.selection = TextSelection(
              baseOffset: 0,
              extentOffset: widget.textEditingController!.text.length);
        }
      },
      decoration: InputDecoration(
        floatingLabelAlignment: FloatingLabelAlignment.center,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
        labelText: widget.labelText,
        // Center the text
        alignLabelWithHint: true,
      ),
    );
  }
}
