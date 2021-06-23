import 'dart:ui';

import 'package:flutter/material.dart';

class ScreenSizeUtil {
  static double getScreenHeight() {
    return MediaQueryData.fromWindow(window).size.height;
  }

  static double getScreenWidth() {
    return MediaQueryData.fromWindow(window).size.width;
  }

  static double get screenWidth => MediaQueryData.fromWindow(window).size.width;

  /// 系统状态栏高度
  static double get stateBarHeigth =>
      MediaQueryData.fromWindow(window).padding.top;
}
