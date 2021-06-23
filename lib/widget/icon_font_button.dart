import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// 使用字体图标的按钮
class IconFontButton extends StatelessWidget {
  const IconFontButton(
    this.codePoint, {
    Key? key,
    this.onPressed,
    this.color = const Color(0xFFDDDDDD),
    this.size = 24,
  }) : super(key: key);

  /// 值
  final int codePoint;

  /// 点击事件
  final VoidCallback? onPressed;

  /// 颜色
  final Color color;

  /// 大小
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        IconData(codePoint, fontFamily: "iconfont"),
        color: color,
        size: size,
      ),
      onPressed: onPressed,
    );
  }
}
