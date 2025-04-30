import 'package:flutter/material.dart';

Widget atsDropdown<T>({
  required T? value,
  required List<T> items,
  required void Function(T?) onChanged,
  required String labelText,
  Widget? suffix,
}) {
  return DropdownButtonFormField<T>(
    value: value,
    decoration: InputDecoration(
      labelText: labelText,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(50))
      ),
      suffixIcon: suffix,
    ),
    items: items.map((item) {
      return DropdownMenuItem(
        value: item,
        child: Text(item.toString()),
      );
    }).toList(),
    onChanged: onChanged,
  );
} 