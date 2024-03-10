import 'package:flutter/material.dart';

class atsCheckbox extends StatefulWidget {
  atsCheckbox({super.key, this.checked = false});

  bool checked;

  @override
  State<atsCheckbox> createState() => _atsCheckboxState();
}

class _atsCheckboxState extends State<atsCheckbox> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.checked = !widget.checked;
        });
      },
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
            border: Border.all(
                color: widget.checked
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.scrim,
                width: 1),
            color: widget.checked
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30)),
        child: widget.checked
            ? Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              )
            : null,
      ),
    );
  }
}
