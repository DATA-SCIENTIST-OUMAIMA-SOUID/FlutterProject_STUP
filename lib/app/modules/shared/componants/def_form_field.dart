import 'package:flutter/material.dart';
import 'package:super_talab_user/app/data/services/helper.dart';

import '../../../utils/constants.dart';

class defTextFormField extends StatelessWidget {
  var hintText;

  var validator;
  bool obscureText;
  final TextInputType keyboardType;

  late TextEditingController controller;
  Function(String?)? onSaved; // Update the function signature
  defTextFormField({
    super.key,
    required this.validator,
    this.onSaved,
    this.obscureText = false,
    required this.controller,
    required this.hintText,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: double.infinity),
      child: Padding(
        padding: const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
        child: TextFormField(
            onSaved: onSaved,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.next,
            validator: validator,
            controller: controller,
            obscureText: obscureText,
            style: TextStyle(
                fontSize: 18.0,
                color: isDarkMode() ? Colors.white : Colors.black),
            keyboardType: keyboardType,
            cursorColor: Color(COLOR_PRIMARY),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 16, right: 16),
              hintText: hintText,
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide:
                      BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
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
            )),
      ),
    );
  }
}
