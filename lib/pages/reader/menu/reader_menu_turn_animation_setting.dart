import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novel_app/pages/reader/menu/reader_menu_container.dart';
import 'package:novel_app/provider/reader_data_model.dart';
import 'package:novel_app/provider/reader_setting_model.dart';
import 'package:novel_app/util/util.dart';

import 'package:novel_app/util/ytx_ScreenUtil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// 翻页动画设置
class ReaderMenuTurnAnimationSetting extends StatefulWidget {
  ReaderMenuTurnAnimationSetting({Key? key}) : super(key: key);

  @override
  _ReaderMenuTurnAnimationSettingState createState() =>
      _ReaderMenuTurnAnimationSettingState();
}

typedef bool? SettingCallback();

class _ReaderMenuTurnAnimationSettingState
    extends State<ReaderMenuTurnAnimationSetting> {
  /// 阅读设置
  ReaderSettingModel? setting;

  /// 阅读数据
  ReaderDataModel? data;

  /// 获取某种类型的名称
  String getTypeName(TurnAnimationType type) {
    switch (type) {
      case TurnAnimationType.cover:
        return '覆盖';
      case TurnAnimationType.simulation:
        return '仿真';
      case TurnAnimationType.slide:
        return '滑动';
      case TurnAnimationType.none:
        return '无';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    setting = Provider.of<ReaderSettingModel>(context);
    data = Provider.of<ReaderDataModel>(context);
    return ReaderMenuContainer(
      height: 300.w,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 20.w),
            alignment: Alignment.centerLeft,
            child: Text(
              '动画类型',
              style: TextStyle(
                fontSize: 32.w,
                fontWeight: FontWeight.w300,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ),
          SizedBox(height: 20.w),
          Wrap(
            children: [
              item(TurnAnimationType.simulation, 0xe69d),
              item(TurnAnimationType.cover, 0xe613),
              item(TurnAnimationType.slide, 0xe613),
              item(TurnAnimationType.none, 0xe613),
            ],
          ),
        ],
      ),
    );
  }

  Widget item(TurnAnimationType type, int codePoint) {
    var _is = setting!.turnAnimationType == type;
    var color = Color(0xFFFFFFFF);
    if (_is) {
      color = Color(0xFF3B9AFF);
    }
    return Container(
      // width: 223.w,
      // width: 223.w,
      margin: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(color: color, width: 1.w),
      ),
      child: TextButton(
        onPressed: () {
          print(11);
          if (!_is) {
            setting!.setTurnAnimationType(type);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              IconData(codePoint, fontFamily: "iconfont"),
              color: color,
              size: 40.w,
            ),
            SizedBox(height: 10.w),
            Text(
              getTypeName(type),
              style: TextStyle(
                fontSize: 28.w,
                color: color,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Timer? t;

  /// 加减字体大小的按钮
  Widget sizeBtn(
    int codePoint, {
    required SettingCallback callback,
    double? iconSize,
  }) {
    var _iconSize = iconSize ?? 42.w;
    return GestureDetector(
      onTap: () {
        callback();
      },
      onLongPressStart: (e) {
        print('onLongPressStart');
        // 开始长按后,设置一个计时器,持续更新fontSize
        t = Timer.periodic(Duration(milliseconds: 80), (timer) {
          var _is = callback();
          if (_is == true) {
            timer.cancel();
          }
        });
      },
      onLongPressEnd: (e) {
        print("长按结束");
        t?.cancel();
      },
      child: Container(
        width: 130.w,
        height: 70.w,
        decoration: BoxDecoration(
          // color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(90.w),
          border: Border.all(color: Color(0xFFFFFFFF), width: 1.w),
        ),
        alignment: Alignment.center,
        child: Container(
          child: Icon(
            IconData(codePoint, fontFamily: "iconfont"),
            color: Color(0xFFDDDDDD),
            size: _iconSize,
          ),
        ),
      ),
    );
  }

  Widget valueText(int size) {
    return Container(
      alignment: Alignment.center,
      constraints: BoxConstraints(minWidth: 160.w),
      child: Text(
        '$size',
        style: TextStyle(
          fontSize: 30.w,
          color: Color(0xFFFFFFFF),
        ),
      ),
    );
  }
}
