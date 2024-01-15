import 'package:flutter/material.dart';

import '../../../data/services/helper.dart';

class Custom_State_Text extends StatelessWidget {
  final String text;

  final VoidCallback onPress;
  const Custom_State_Text(
      {super.key, required this.text, required this.onPress});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, top: 6),
      child: Column(
        children: [
          TextButton(
            onPressed: onPress,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                text,
                style: TextStyle(
                  color: isDarkMode() ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontFamily: "Poppinsr",
                ),
              ),
            ),
          ),
          const Divider(
            thickness: 0.8,
          ),
        ],
      ),
    );
  }
}
