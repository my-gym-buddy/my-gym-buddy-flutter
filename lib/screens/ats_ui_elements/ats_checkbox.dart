import 'package:flutter/material.dart';

class atsCheckbox extends StatefulWidget {
  atsCheckbox(
      {super.key,
      this.checked = false,
      this.onChanged,
      this.onHold,
      this.child,
      this.width = 30,
      this.height = 30});

  bool checked;

  Widget? child;

  double width = 30;
  double height = 30;

  Function? onChanged;
  Function? onHold;

  @override
  State<atsCheckbox> createState() => _atsCheckboxState();
}

class _atsCheckboxState extends State<atsCheckbox> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (widget.onHold != null) {
          widget.onHold!();
        }
      },
      onTap: () {
        setState(() {
          widget.checked = !widget.checked;
          if (widget.onChanged != null) {
            widget.onChanged!(widget.checked);
          }
        });
      },
      child: Container(
          height: widget.height,
          width: widget.width,
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
          child: widget.child ??
              Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              )),
    );
  }
}
