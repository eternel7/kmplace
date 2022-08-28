import 'package:flutter/material.dart';

class TextFieldFormInput extends StatefulWidget {
  const TextFieldFormInput(
      {Key? key,
      this.maxLines = 1,
      required this.text,
      required this.labelText,
      required this.textFieldKey,
      required this.onChanged})
      : super(key: key);
  final int maxLines;
  final String text;
  final String labelText;
  final Key textFieldKey;
  final Function onChanged;

  @override
  State<TextFieldFormInput> createState() => _TextFieldFormInputState();
}

class _TextFieldFormInputState extends State<TextFieldFormInput> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      controller.text = widget.text;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: widget.textFieldKey,
      controller: controller,
      onChanged: (val) => widget.onChanged(val),
      decoration: InputDecoration(filled: true, labelText: widget.labelText),
      maxLines: widget.maxLines,
    );
  }
}
