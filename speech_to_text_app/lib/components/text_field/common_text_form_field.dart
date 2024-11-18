import 'package:flutter/material.dart';

class CommonTextFormField extends StatelessWidget {
  const CommonTextFormField({
    Key? key,
    required this.controller,
    required this.keyboardType,
    required this.hintText,
    required this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  }) : super(key: key);

  final TextEditingController controller;
  final TextInputType keyboardType;
  final String hintText;
  final String? Function(String?) validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final AutovalidateMode autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText,
      autovalidateMode: autovalidateMode,
      validator: validator,
    );
  }
}
