import 'package:flutter/material.dart';


class atsTextField extends StatefulWidget {
  atsTextField(
      {super.key,
      required this.labelText,
      this.textEditingController,
      this.onEditingComplete,
      this.keyboardType,
      this.enabled = true,
      this.onChanged,
      this.textAlign = TextAlign.start,
      this.selectAllOnTap = false,
      this.minLines = 1,
      this.maxLines = 1,
      this.error = false});

  final TextEditingController? textEditingController;
  final String labelText;

  final TextInputType? keyboardType;

  final bool selectAllOnTap;

  final bool enabled;

  Function? onEditingComplete;
  Function? onChanged;

  final int minLines;
  final int maxLines;

  TextAlign textAlign = TextAlign.start;

  final bool error;

  @override
  State<atsTextField> createState() => _atsTextFieldState();
}

class _atsTextFieldState extends State<atsTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        textAlign: widget.textAlign,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          floatingLabelAlignment: FloatingLabelAlignment.center,
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            borderSide: BorderSide(
              color: widget.error ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outline,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            borderSide: BorderSide(
              color: widget.error ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outline,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            borderSide: BorderSide(
              color: widget.error ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
            ),
          ),
          labelText: widget.labelText,
          labelStyle: TextStyle(
            color: widget.error ? Theme.of(context).colorScheme.error : null,
          ),
        ));
  }
}
