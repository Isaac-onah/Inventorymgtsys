//NOTE ----------default Button -----------------------------
import 'package:flutter/material.dart';

Widget defaultButton(
        {double width = double.infinity,
        Color background = Colors.green,
        VoidCallback? onpress,
        required String text,
        double radius = 10,
        double height = 40,
        LinearGradient? gradient,
        bool? isUppercase}) =>
    Container(
      width: width,
      child: MaterialButton(
        height: height,
        onPressed: onpress,
        child: Text(
          (isUppercase != null && isUppercase) ? text.toUpperCase() : text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: background,
          gradient: gradient),
    );
