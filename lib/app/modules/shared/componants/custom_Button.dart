// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../../../data/services/helper.dart';
import '../../../utils/constants.dart';

class CustomButton extends StatelessWidget {
  final Size? size;

  final String text;
  final Color color;
  final VoidCallback onPress;
  const CustomButton(
      {super.key,
      required this.text,
      required this.onPress,
      required this.color,
      this.size});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          animationDuration: const Duration(milliseconds: 500),
          minimumSize: Size(
            MediaQuery.of(context).size.width * 0.9,
            MediaQuery.of(context).size.height * 0.06,
            // set width to 40% of screen width
            // set height to 7% of screen height
          )),
      onPressed: onPress,
      child: CustomText(
        text: text,
        alignment: Alignment.center,
        color: isDarkMode() ? Color(COLOR_PRIMARY) : Colors.white,
        bold: FontWeight.normal,
      ),
    );
  }
}

// ignore_for_file: prefer_const_constructors_in_immutables

class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight? bold;
  final Color color;
  final Alignment alignment;

  CustomText(
      {super.key,
      this.text = "",
      this.fontSize = 18,
      this.color = Colors.black,
      this.alignment = Alignment.topLeft,
      this.bold});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.normal,
          color: color,
          fontSize: fontSize,
        ),
      ),
    );
  }
}



/* MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(18),
          color: primaryColor,
          onPressed: onPress(),
          child: CustomText(
            text: text,
            alignment: Alignment.center,
            color: Colors.white,
          )),*/

/*ElevatedButton(
      style: ElevatedButton.styleFrom(
        //change the button's background color
        primary: primary,
        //colors of text,icon,hover,focus,pressed
        onPrimary: const Color(0xff01BAEF),
        elevation: 10,
        //gives padding to the button
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        //set minimum size for the button of (width, height)
        minimumSize: const Size(270, 56),
        //shape of the button
        shape: const StadiumBorder(),
        //the speed of the hover animation
        animationDuration: const Duration(milliseconds: 500),
        // textStyle: TextStyle(
        //   //this color will not overwrite the onPrimary text color
        //   color: Colors.green,
        //   fontSize: 20,
        //   fontWeight: FontWeight.bold,
        // ),
      ),
      child: Text(text, style: style),
      onPressed: onTap,
    );*/