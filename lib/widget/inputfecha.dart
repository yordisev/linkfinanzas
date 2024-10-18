import 'dart:convert';
import 'dart:io';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InputText extends StatefulWidget {
  final String label;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final TextEditingController? controllerfile;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool isVisible;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final bool isCalendar;
  final String? initialValue;
  final bool isFile;
  final TextStyle? labelStyle;
  final bool? filled;
  final Color? fillColor;
  final Color? colorError;
  final FloatingLabelBehavior? floatingLabelBehavior;

  const InputText({
    super.key,
    required this.label,
    this.suffixIcon,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.isVisible = false,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.isCalendar = false,
    this.initialValue,
    this.isFile = false,
    this.controllerfile,
    this.labelStyle,
    this.filled = false,
    this.fillColor = Colors.transparent,
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
    this.colorError,
  });

  @override
  State<InputText> createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  bool isVisible = false;
  String filePath = "";
  @override
  Widget build(BuildContext context) {
    widget.initialValue != null
        ? widget.controller.text == widget.initialValue
        : null;

    void dialogFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        File file = File(result.files.single.path ?? " ");
        widget.controller.text = file.path.split('/').last;
        widget.controllerfile!.text = result.files.single.path ?? "";
        // filePath = file.path;
        // final bytes = File(filePath).readAsBytesSync();
        // String img64 = base64Encode(bytes);
        // print(widget.controller.text);
        // print(img64);
      }
    }

    void dialogCalendar() async {
      final values = await showCalendarDatePicker2Dialog(
        context: context,
        config: CalendarDatePicker2WithActionButtonsConfig(
          firstDate: DateTime(1980, 1, 1),
          lastDate: DateTime.now(),
          currentDate: DateTime.now(),
          dayTextStyle:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
          calendarType: CalendarDatePicker2Type.single,
          selectedDayHighlightColor: Colors.green,
          closeDialogOnCancelTapped: true,
          firstDayOfWeek: 1,
          weekdayLabelTextStyle: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          controlsTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          centerAlignModePicker: true,
          customModePickerIcon: const SizedBox(),
          selectedDayTextStyle:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        dialogSize: const Size(325, 400),
        borderRadius: BorderRadius.circular(15),
        dialogBackgroundColor: Colors.white,
      );
      if (values != null && values.isNotEmpty) {
        setState(() {
          widget.controller.text =
              DateFormat('yyyy-MM-dd', "es_ES").format(values[0]!);
        });
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          obscureText: widget.isPassword ? !isVisible : isVisible,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          readOnly: widget.isFile ? true : widget.readOnly,
          validator: widget.validator,
          onTap: () {
            widget.isFile
                ? dialogFile()
                : widget.isCalendar
                    ? dialogCalendar()
                    : null;
          },
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            label: Text(widget.label),
            floatingLabelBehavior: widget.floatingLabelBehavior,
            labelStyle: TextStyle(color: Colors.green),
            suffixIconColor: Colors.green,
            filled: widget.filled,
            fillColor: widget.fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isVisible = !isVisible;
                      });
                    },
                    icon: Icon(
                        isVisible ? Icons.visibility_off : Icons.visibility))
                : widget.isFile
                    ? IconButton(
                        onPressed: () => dialogFile(),
                        icon: const Icon(Icons.file_present))
                    : widget.isCalendar
                        ? IconButton(
                            onPressed: () => dialogCalendar(),
                            icon: const Icon(Icons.calendar_month))
                        : widget.suffixIcon,
            errorStyle: TextStyle(
                color: widget.colorError ?? Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          )),
    );
  }
}
