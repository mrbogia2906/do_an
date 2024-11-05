import 'package:flutter/material.dart';
import 'package:speech_to_text_app/resources/gen/colors.gen.dart';
import 'package:speech_to_text_app/resources/gen/fonts.gen.dart';

class AppTextStyles {
  AppTextStyles._();
  static const defaultStyle = TextStyle(
    fontFamily: FontFamily.notoSans,
    color: ColorName.black,
  );

  static final bottomBarItem = defaultStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  static final bottomBarItemOn = defaultStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  static final s12w400 = defaultStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static final s12w700 = defaultStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static final s14w400 = defaultStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static final s14w500 = defaultStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static final s14w700 = defaultStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static final s16w400 = defaultStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static final s16w700 = defaultStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static final s18w700 = defaultStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static final s20w400 = defaultStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w400,
  );

  static final s20w700 = defaultStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static final s21w700 = defaultStyle.copyWith(
    fontSize: 21,
    fontWeight: FontWeight.w700,
  );

  static final s22w700 = defaultStyle.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static final s24w700 = defaultStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static final s30w600 = defaultStyle.copyWith(
    fontSize: 30,
    fontWeight: FontWeight.w600,
  );

  static final s38w700 = defaultStyle.copyWith(
    fontSize: 38,
    fontWeight: FontWeight.w700,
  );

  static final s40w700 = defaultStyle.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static final overView = defaultStyle.copyWith(
    fontSize: 16,
    height: 1.5,
  );

  static final tagLine = defaultStyle.copyWith(
    fontSize: 16,
    height: 1.5,
    fontStyle: FontStyle.italic,
  );
}
