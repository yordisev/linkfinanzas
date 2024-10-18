import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  const Input({
    super.key,
    this.onChanged,
    required this.controllertext,
    required this.label,
    required this.icono,
  });

  final void Function(String)? onChanged;
  final TextEditingController controllertext;
  final String label;
  final Icon icono;

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controllertext,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.green.shade200,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: widget.icono,
        prefixIconColor: Colors.green,
        labelText: widget.label,
        labelStyle: TextStyle(color: Colors.grey),
      ),
    );
  }
}
