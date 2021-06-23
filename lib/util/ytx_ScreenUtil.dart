// import 'package:flutter_screenutil/screen_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension SizeExtension on num {
  ///[ScreenUtil.setWidth]
  ///自己加了r=rem的简称,仿css写法
  double get r => ScreenUtil().setWidth(this);

  ///[ScreenUtil.setWidth]
  ///自己加了r=rem的简称,仿css写法
  double get rem => ScreenUtil().setWidth(this);

  /// 原来的sw的1% 效果=css vw
  double get vw => ScreenUtil().screenWidth * this * 0.01;

  ///原来的sh的1% 效果=css vh
  double get vh => ScreenUtil().screenHeight * this * 0.01;
}
