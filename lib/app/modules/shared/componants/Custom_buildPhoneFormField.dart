import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../utils/constants.dart';

class Custom_PhoneNumber_TextFormfield extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? type;
  final FormFieldValidator<String>? validate;
  final String? labelText;
  final IconData? suffix;
  final String? hintText;

  final Function()? onTap;
  final Widget? suffixWidget;
  final TextStyle? textStyle;
  final FontWeight? fontWeight;
  void Function(PhoneNumber?)? onSaved;
  void Function(PhoneNumber)? onChanged;
  final TextInputAction? textInputAction;

  Custom_PhoneNumber_TextFormfield(
      {Key? key,
      this.onChanged,
      this.controller,
      this.type,
      this.validate,
      this.labelText,
      this.suffix,
      this.onTap,
      this.suffixWidget,
      this.textStyle,
      this.fontWeight,
      this.textInputAction,
      this.hintText,
      this.onSaved})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double labelFontSize = screenSize.width < 500 ? 16 : 18;
    final double inputFontSize = screenSize.width < 500 ? 18 : 21;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: double.infinity),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 25.0,
          right: 24.0,
          left: 24.0,
        ),
        child: IntlPhoneField(
            onSaved: onSaved,
            textAlignVertical: TextAlignVertical.center,
            controller: controller,
            textInputAction: textInputAction,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 16, right: 16),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide:
                      BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
              border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color(COLOR_PRIMARY), width: 2.0),
                  borderRadius: BorderRadius.circular(20)),
              errorBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.error),
                borderRadius: BorderRadius.circular(25.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.error),
                borderRadius: BorderRadius.circular(25.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(25.0),
              ),
              hintText: hintText,
              hintStyle: textStyle ??
                  TextStyle(
                    fontSize: inputFontSize,
                    fontWeight: FontWeight.normal,
                  ),
              filled: true,
              labelText: labelText,
              labelStyle: TextStyle(
                fontSize: labelFontSize,
                fontWeight: fontWeight,
              ),
            ),
            initialCountryCode: 'EG',
            onChanged: onChanged
            //     (phone) {
            //
            // },
            ),
      ),
    );
  }
}
