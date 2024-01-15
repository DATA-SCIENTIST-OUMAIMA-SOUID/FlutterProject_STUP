import 'package:flutter/material.dart';

import '../../../utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? type;
  final String? labelText;
  final String? initialValue;
  final String? hintText;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final FormFieldSetter<String>? onChanged;
  final FormFieldSetter<String>? onSubmitted;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputAction? textInputAction;
  final FontWeight? fontWeight;
  final int? maxline;
  final TextStyle? textStyle;
  final Color? prefixIconColor;

  const CustomTextField(
      {super.key,
      this.prefixIcon,
      this.controller,
      this.labelText,
      this.hintText,
      this.obscureText = false,
      this.validator,
      this.onSaved,
      this.suffixIcon,
      this.type,
      this.textInputAction,
      this.fontWeight,
      this.maxline,
      this.textStyle,
      this.onSubmitted,
      this.onChanged,
      this.initialValue,
      this.prefixIconColor});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    final Size screenSize = MediaQuery.of(context).size;
    final double labelFontSize = screenSize.width < 500 ? 16 : 18;
    final double inputFontSize = screenSize.width < 500 ? 18 : 21;
    final double iconSize = screenSize.width < 600 ? 20 : 24;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: TextFormField(
        cursorColor: Color(COLOR_PRIMARY),
        initialValue: initialValue,
        onChanged: onChanged,
        maxLines: maxline,
        controller: controller,
        textInputAction: textInputAction,
        decoration: InputDecoration(
            filled: true,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white)),
            prefixIcon: prefixIcon,
            prefixIconColor: prefixIconColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white)),
            labelText: labelText,
            labelStyle: TextStyle(
              fontSize: labelFontSize,
              fontWeight: fontWeight,
            ),
            hintText: hintText,
            hintStyle: textStyle ??
                TextStyle(
                  fontSize: inputFontSize,
                  fontWeight: FontWeight.normal,
                ),
            suffixIcon: suffixIcon),
        obscureText: obscureText,
        validator: validator,
        onFieldSubmitted: onSubmitted,
        onSaved: onSaved,
        style: TextStyle(fontSize: inputFontSize),
        keyboardType: type,
      ),
    );
  }
}
