import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swrv/utils/utilthemes.dart';

class CusBtn extends HookWidget {
  final Color btnColor;
  final String btnText;
  final double textSize;
  final Function btnFunction;
  final double btnRadius;
  final Color textColor;
  final double elevation;
  const CusBtn({
    Key? key,
    required this.btnColor,
    required this.btnText,
    required this.textSize,
    required this.btnFunction,
    this.btnRadius = 10,
    this.textColor = whiteC,
    this.elevation = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(elevation),
        backgroundColor: MaterialStateProperty.all(btnColor),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(btnRadius)),
        ),
        minimumSize: MaterialStateProperty.all(const Size.fromHeight(40)),
      ),
      onPressed: () {
        btnFunction();
      },
      child: Text(
        btnText,
        textAlign: TextAlign.center,
        textScaleFactor: 1,
        style: GoogleFonts.openSans(
          color: textColor,
          fontSize: textSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
