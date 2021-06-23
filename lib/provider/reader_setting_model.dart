import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:novel_app/class/save_change_notifier.dart';
import 'package:novel_app/util/convert/color_json_converter.dart';
import 'package:novel_app/util/convert/turn_animation_type_json_converter.dart';
import 'package:novel_app/util/util.dart';

part 'reader_setting_model.g.dart';

/// 翻页动画类型
enum TurnAnimationType {
  /// 覆盖
  cover,

  /// 仿真
  simulation,

  /// 滑动
  slide,

  /// 没有
  none,
}

var _readerSettingKey = '_readerSettingKey';

// import 'package:provider/provider.dart';+
/// 所有阅读设置的模型
/// 存储所有阅读相关的设置(但不包含书签等)
@JsonSerializable(
  createFactory: true,
  createToJson: true,
  includeIfNull: true,
)
class ReaderSettingModel extends SaveChangeNotifier {
  ReaderSettingModel();
  factory ReaderSettingModel.fromMMKV() {
    var map = NovelUtil.data.getJsonMap(_readerSettingKey);
    var json = map as Map<String, dynamic>;
    // 因为这个框架没有对null值的判断,所以我只能手动判断空值
    if (json['fontSize'] == null) {
      json = ReaderSettingModel().toJson();
    }
    return _$ReaderSettingModelFromJson(json);
  }

  /// 初始化
  Future<void> init([parm]) async {}

  /// 读取配置以初始化
  Future<void> read() async {}

  /// 保存配置
  void save() {
    var s = json.encode(toJson());
    NovelUtil.data.setString(_readerSettingKey, s);
  }

  /// 用json初始化
  factory ReaderSettingModel.fromJson(Map<String, dynamic> json) =>
      _$ReaderSettingModelFromJson(json);

  /// 转化为json
  Map<String, dynamic> toJson() => _$ReaderSettingModelToJson(this);

  /// 背景颜色
  @ColorJsonConverter()
  Color backgroundColor = Color(0xFFcce7d1);

  /// 设置 背景颜色
  void setBackgroundColor(Color color) {
    backgroundColor = color;
    saveChange();
  }

  /****************
   *  字体相关
   ****************/
  /// 字体大小
  double fontSize = 40.w;

  /// 设置 字体大小
  void setFontSize(double size) {
    fontSize = size;
    saveChange();
  }

  /// 字体行高
  double lineHeight = 1.5;

  /// 设置 字体行高
  void setLineHeight(double height) {
    lineHeight = height;
    saveChange();
  }

  /// 标题字体大小
  double titleFontSize = 50.w;

  /// 设置标题字体大小
  void setTitleFontSize(double size) {
    titleFontSize = size;
    saveChange();
  }

  /// 标题字体行高
  double titleLineHeight = 1.5;

  /// 设置标题字体行高
  void setTitleLineHeight(double height) {
    titleLineHeight = height;
    saveChange();
  }

  /// 段落间距
  double sectionSpace = 20.w;

  /// 设置 段落间距
  void setSectionSpace(double size) {
    sectionSpace = size;
    saveChange();
  }

  /// 字体颜色
  @ColorJsonConverter()
  Color color = Color(0xFF444444);

  /// 设置字体颜色
  void setColor(Color _color) {
    color = _color;
    //  notifyListeners();
    saveChange();
  }

  /// 首行缩进
  int indent = 8;

  String? _indentString;

  String get indentString =>
      _indentString == null ? _initIndentString() : _indentString!;

  String _initIndentString() {
    var v = "";
    for (var i = 0; i < indent; i++) v += " ";
    return _indentString = v;
  }

  /// 设置 字体行高
  void setIndent(int v) {
    indent = v;
    _indentString = null;
    saveChange();
  }

  /****************
   *    布局
   ****************/
  /// 顶部安全区
  double headerTopOffset = 10.w;

  /// 设置 顶部安全区
  void setHeaderTopOffset(double size) {
    headerTopOffset = size;
    saveChange();
  }

  /// 顶部安全区-左侧
  double headerLeftOffset = 100.w;

  /// 设置 顶部安全区-右侧
  void setHeaderLeftOffset(double size) {
    headerLeftOffset = size;
    saveChange();
  }

  /// 顶部安全区-右侧
  double headerRightOffset = 40.w;

  /// 设置 顶部安全区-右侧
  void setHeaderRightOffset(double size) {
    headerRightOffset = size;
    saveChange();
  }

  /// 底部安全区
  double footerBottomOffset = 0.w;

  /// 设置 底部安全区
  void setFooterBottomOffset(double size) {
    footerBottomOffset = size;
    saveChange();
  }

  /// 底部安全区-左右
  double footerHorizontalOffset = 40.w;

  /// 设置 底部安全区-左右
  void setFooterHorizontalOffset(double size) {
    footerHorizontalOffset = size;
    saveChange();
  }

  /// 内容左右间距
  double contentHorizontalPadding = 30.w;

  /// 设置 内容左右间距
  void setContentHorizontalPadding(double v) {
    contentHorizontalPadding = v;
    saveChange();
  }

  /// 内容顶部间距
  double contentToplPadding = 30.w;

  /// 设置 内容顶部间距
  void setContentToplPadding(double v) {
    contentToplPadding = v;
    saveChange();
  }

  /// 内容底部间距
  double contentBottomlPadding = 30.w;

  /// 设置 内容底部间距
  void setContentBottomlPadding(double v) {
    contentBottomlPadding = v;
    saveChange();
  }

  /// 翻页动画类型,
  // @TurnAnimationTypeJsonConverter()
  @JsonKey(defaultValue: TurnAnimationType.cover)
  TurnAnimationType turnAnimationType = TurnAnimationType.cover;

  /// 设置 内容底部间距
  void setTurnAnimationType(TurnAnimationType type) {
    turnAnimationType = type;
    saveChange();
  }
}
