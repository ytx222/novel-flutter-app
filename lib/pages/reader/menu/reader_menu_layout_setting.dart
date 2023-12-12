import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novel_app/pages/reader/menu/reader_menu_container.dart';
import 'package:novel_app/provider/reader_data_model.dart';
import 'package:novel_app/provider/reader_setting_model.dart';
import 'package:novel_app/util/util.dart';

import 'package:novel_app/util/ytx_ScreenUtil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// 布局设置,包含以下项目的设置
/// - 顶部安全区
/// - 顶部安全区-左侧
/// - 顶部安全区-右侧
/// - 底部安全区
/// - 底部安全区-左右
/// - 内容左右间距
/// - 内容顶部间距
/// - 内容底部间距
class ReaderMenuLayoutSetting extends StatefulWidget {
  ReaderMenuLayoutSetting({Key? key}) : super(key: key);

  @override
  _ReaderMenuColorLayoutngState createState() =>
      _ReaderMenuColorLayoutngState();
}

/// 设置类型
enum _SettingType {
  ///顶部安全区
  headerTopOffset,

  ///顶部安全区-左侧
  headerLeftOffset,

  ///顶部安全区-右侧
  headerRightOffset,

  ///底部安全区
  footerBottomOffset,
  //底部安全区-/左右
  footerHorizontalOffset,

  ///内容左右间距
  contentHorizontalPadding,

  ///内容顶部间距
  contentToplPadding,

  ///内容底部间距
  contentBottomlPadding
}

typedef bool? SettingCallback();

class _ReaderMenuColorLayoutngState extends State<ReaderMenuLayoutSetting> {
  /// 阅读设置
  ReaderSettingModel? setting;

  /// 阅读数据
  ReaderDataModel? data;

  /// 获取某种类型的名称
  String getTypeName(_SettingType type) {
    switch (type) {
      case _SettingType.headerTopOffset:
        return '顶部安全区';
      case _SettingType.headerLeftOffset:
        return '顶部安全区-左侧';
      case _SettingType.headerRightOffset:
        return '顶部安全区-右侧';
      case _SettingType.footerBottomOffset:
        return '底部安全区';
      case _SettingType.contentHorizontalPadding:
        return '内容左右间距';
      case _SettingType.contentToplPadding:
        return '内容顶部间距';
      case _SettingType.contentBottomlPadding:
        return '内容底部间距';
      default:
        return '';
    }
  }

  /// 获取某种类型的值
  double getTypeValue(_SettingType type) {
    if (setting == null) {
      return 0;
    }
    switch (type) {
      case _SettingType.headerTopOffset:
        return setting!.headerTopOffset;
      case _SettingType.headerLeftOffset:
        return setting!.headerLeftOffset;
      case _SettingType.headerRightOffset:
        return setting!.headerRightOffset;
      case _SettingType.footerBottomOffset:
        return setting!.footerBottomOffset;
      case _SettingType.contentHorizontalPadding:
        return setting!.contentHorizontalPadding;
      case _SettingType.contentToplPadding:
        return setting!.contentToplPadding;
      case _SettingType.contentBottomlPadding:
        return setting!.contentBottomlPadding;
      default:
        return 0;
    }
  }

  /// 设置某种类型的值
  void setTypeValue(_SettingType type, double value) {
    switch (type) {
      case _SettingType.headerTopOffset:
        setting!.setHeaderTopOffset(value);
        break;
      case _SettingType.headerLeftOffset:
        setting!.setHeaderLeftOffset(value);
        return; // 使用return是因为不需要重新计算布局
      case _SettingType.headerRightOffset:
        setting!.setHeaderRightOffset(value);
        return; // 使用return是因为不需要重新计算布局
      case _SettingType.footerBottomOffset:
        setting!.setFooterBottomOffset(value);
        break;
      case _SettingType.contentHorizontalPadding:
        setting!.setContentHorizontalPadding(value);
        break;
      case _SettingType.contentToplPadding:
        setting!.setContentToplPadding(value);
        break;
      case _SettingType.contentBottomlPadding:
        setting!.setContentBottomlPadding(value);
        break;
      case _SettingType.footerHorizontalOffset:
        setting!.setFooterHorizontalOffset(value);
        return; // 使用return是因为不需要重新计算布局
    }
    data!.refreshChapterContent();
  }

  @override
  Widget build(BuildContext context) {
    setting = Provider.of<ReaderSettingModel>(context);
    data = Provider.of<ReaderDataModel>(context);
    return ReaderMenuContainer(
      child: Column(
        children: [
          item(_SettingType.headerTopOffset),
          item(_SettingType.headerLeftOffset),
          item(_SettingType.headerRightOffset),
          item(_SettingType.footerBottomOffset),
          item(_SettingType.contentHorizontalPadding),
          item(_SettingType.contentToplPadding),
          item(_SettingType.contentBottomlPadding),
        ],
      ),
    );
  }

  Widget item(_SettingType type) {
    var value = getTypeValue(type);
    var size = (value / 1.w).round();
    return Container(
      margin: EdgeInsets.all(10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 10.w),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              constraints: BoxConstraints(minWidth: 140.w),
              child: Text(
                getTypeName(type),
                style: TextStyle(
                  fontSize: 30.w,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
          sizeBtn(
            const IconData(0xe6f7, fontFamily: "iconfont"),
            callback: () {
              if (size - 1 < 0) {
                NovelUtil.msg('不能再小了');
                return true;
              }
              var newValue = 1.w * --size;
              setTypeValue(type, newValue);
            },
          ),
          valueText(size),
          sizeBtn(
            const IconData(0xe663, fontFamily: "iconfont"),
            callback: () {
              const max = 600;
              if (size + 1 > max) {
                NovelUtil.msg('间距上限为${max}');
                return true;
              }
              var newValue = 1.w * ++size;
              setTypeValue(type, newValue);
            },
          ),
        ],
      ),
    );
  }

  Timer? t;

  /// 加减字体大小的按钮
  Widget sizeBtn(
    IconData iconData, {
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
            iconData,
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
