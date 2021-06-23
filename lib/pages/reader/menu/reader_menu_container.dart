import 'package:flutter/material.dart';

import 'package:novel_app/util/ytx_ScreenUtil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 一个包裹阅读菜单项的容器,提供一些公用样式
class ReaderMenuContainer extends StatelessWidget {
  /// 内容
  final Widget? child;
  final double? height;
  final EdgeInsets? padding;
  const ReaderMenuContainer({
    Key? key,
    this.child,
    this.height,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _padding = padding ?? EdgeInsets.all(10.w);
    var _h = height ?? 500.w;
    // ColorScheme.secondary
    return Stack(
      children: [
        Positioned.fill(
          top: null,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF3F3F3F),
            ),
            height: _h,
            padding: _padding,
            child: ScrollConfiguration(
              behavior: ScrollBehavior(),
              child: SingleChildScrollView(
                child: child,
              ),
            ),
          ),
        )
      ],
    );
  }
}
