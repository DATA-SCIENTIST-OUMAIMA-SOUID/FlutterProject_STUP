import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/helper.dart';
import '../../../utils/constants.dart';

class buildTitleRow extends StatelessWidget {
  final String titleValue;
  final Function? onClick;
  final bool? isViewAll;

  const buildTitleRow({
    Key? key,
    required this.titleValue,
    this.onClick,
    this.isViewAll = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDarkMode() ? const Color(DARK_COLOR) : const Color(0xffFFFFFF),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titleValue.tr,
                  style: TextStyle(
                      color:
                          isDarkMode() ? Colors.white : const Color(0xFF000000),
                      fontFamily: "Poppinsm",
                      fontSize: 18)),
              isViewAll!
                  ? Container()
                  : GestureDetector(
                      onTap: () {
                        onClick!.call();
                      },
                      child: Text('View All'.tr,
                          style: TextStyle(
                              color: Color(COLOR_PRIMARY),
                              fontFamily: "Poppinsm")),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
