import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novel_app/pages/reader/menu/reader_menu_container.dart';
import 'package:novel_app/provider/reader_data_model.dart';
import 'package:novel_app/provider/reader_setting_model.dart';
import 'package:novel_app/util/util.dart';

import 'package:novel_app/util/ytx_ScreenUtil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ReaderMenuFontSetting extends StatefulWidget {
  ReaderMenuFontSetting({Key? key}) : super(key: key);

  @override
  _ReaderMenuFontSettingState createState() => _ReaderMenuFontSettingState();
}

class _ReaderMenuFontSettingState extends State<ReaderMenuFontSetting> {
  /// 设置
  ReaderSettingModel? setting;

  ///
  ReaderDataModel? data;

  @override
  Widget build(BuildContext context) {
    // final int iconFontAdd = 0xe689;
    // final int iconFontReduce = 0xe6c4;
    // final int iconAdd = 0xe663;
    // final int iconReduce = 0xe6f7;

    final IconData iconFontAdd = const IconData(0xe689, fontFamily: "iconfont");
    final IconData iconFontReduce =
        const IconData(0xe6c4, fontFamily: "iconfont");
    final IconData iconAdd = const IconData(0xe663, fontFamily: "iconfont");
    final IconData iconReduce = const IconData(0xe6f7, fontFamily: "iconfont");
    setting = Provider.of<ReaderSettingModel>(context);
    data = Provider.of<ReaderDataModel>(context);
    return ReaderMenuContainer(
      height: 620.w,
      // height: 420.w,
      child: Column(
        children: [
          SizedBox(
            height: 30.w,
          ),
          row([
            title('标题'),
            sizeBtn(
              iconFontReduce,
              iconSize: 64.w,
              callback: () {
                var size = setting!.titleFontSize - 1.w;
                if ((size / 1.w).round() <= 10) {
                  NovelUtil.msg('不能再小了');
                } else {
                  setting!.setTitleFontSize(size);
                  data!.refreshChapterContent();
                }
              },
            ),
            sizeTxt(setting!.titleFontSize),
            sizeBtn(
              iconFontAdd,
              iconSize: 60.w,
              callback: () {
                var size = setting!.titleFontSize + 1.w;
                setting!.setTitleFontSize(size);
                data!.refreshChapterContent();
              },
            ),
          ]),
          row([
            title('正文'),
            sizeBtn(
              iconFontReduce,
              iconSize: 64.w,
              callback: () {
                var size = setting!.fontSize - 1.w;
                if ((size / 1.w).round() <= 10) {
                  NovelUtil.msg('不能再小了');
                } else {
                  setting!.setFontSize(size);
                  data!.refreshChapterContent();
                }
              },
            ),
            sizeTxt(setting!.fontSize),
            sizeBtn(
              iconFontAdd,
              iconSize: 60.w,
              callback: () {
                var size = setting!.fontSize + 1.w;
                setting!.setFontSize(size);
                data!.refreshChapterContent();
              },
            ),
          ]),
          row([
            title('标题行高'),
            sizeBtn(
              iconReduce,
              iconSize: 38.w,
              callback: () {
                var h = setting!.titleLineHeight - 0.1;
                if (h < 1) {
                  NovelUtil.msg('行高不能低于1倍');
                } else {
                  setting!.setTitleLineHeight(h);
                  data!.refreshChapterContent();
                }
              },
            ),
            lineHeightTxt(setting!.titleLineHeight),
            sizeBtn(
              iconAdd,
              iconSize: 34.w,
              callback: () {
                var h = setting!.titleLineHeight + 0.1;
                setting!.setTitleLineHeight(h);
                data!.refreshChapterContent();
              },
            ),
          ]),
          row([
            title('正文行高'),
            sizeBtn(
              iconReduce,
              iconSize: 34.w,
              callback: () {
                var h = ((setting!.lineHeight - 0.1) * 10).floorToDouble() / 10;
                if (h < 1) {
                  print(h);
                  NovelUtil.msg('行高不能低于1倍');
                } else {
                  setting!.setLineHeight(h);
                  data!.refreshChapterContent();
                }
              },
            ),
            lineHeightTxt(setting!.lineHeight),
            sizeBtn(iconAdd, iconSize: 34.w, callback: () {
              var h = setting!.lineHeight + 0.1;
              setting!.setLineHeight(h);
              data!.refreshChapterContent();
            }),
          ]),
          row([
            title('段落间距'),
            sizeBtn(iconReduce, iconSize: 34.w, callback: () {
              var size = setting!.sectionSpace - 1.w;
              if (size <= 0) {
                NovelUtil.msg('段落间距不能小于0');
                size = 0;
              }
              setting!.setSectionSpace(size);
              data!.refreshChapterContent();
            }),
            sizeTxt(setting!.sectionSpace),
            sizeBtn(iconAdd, iconSize: 34.w, callback: () {
              var size = setting!.sectionSpace + 1.w;
              setting!.setSectionSpace(size);
              data!.refreshChapterContent();
            }),
          ]),
          row([
            title('首行缩进'),
            sizeBtn(iconReduce, iconSize: 34.w, callback: () {
              var indent = setting!.indent - 1;
              if (indent < 0) {
                NovelUtil.msg('首行缩进不能小于0');
                indent = 0;
              }
              setting!.setIndent(indent);
              data!.refreshChapterContent();
            }),
            centerText("${setting!.indent / 4}"),
            sizeBtn(iconAdd, iconSize: 34.w, callback: () {
              var indent = setting!.indent + 1;
              setting!.setIndent(indent);
              data!.refreshChapterContent();
            }),
          ]),
        ],
      ),
    );
  }

  Widget row(List<Widget> children) {
    return Container(
      margin: EdgeInsets.all(10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }

  Widget title(String text) {
    return Container(
      margin: EdgeInsets.only(right: 15.w),
      constraints: BoxConstraints(minWidth: 220.w),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 34.w,
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w300),
      ),
    );
  }

  ///
  Widget sizeTxt(double size) {
    return centerText('${(size / 1.w).round()}');
  }

  Widget lineHeightTxt(double size) {
    return centerText('${size.toStringAsFixed(1)}');
  }

  Widget centerText(String txt) {
    return Container(
      alignment: Alignment.center,
      constraints: BoxConstraints(minWidth: 140.w),
      child: Text(
        txt,
        style: TextStyle(
          fontSize: 30.w,
          color: Color(0xFFFFFFFF),
        ),
      ),
    );
  }

  Timer? t;

  /// 加减字体大小的按钮
  Widget sizeBtn(
    IconData iconData, {
    required VoidCallback callback,
    double? iconSize,
  }) {
    var _iconSize = iconSize ?? 42.w;
    return GestureDetector(
      onTap: () {
        print("简单点击");
        callback();
        // setState(() => null);
      },
      onLongPressStart: (e) {
        print('onLongPressStart');
        // 开始长按后,设置一个计时器,持续更新fontSize
        t = Timer.periodic(Duration(milliseconds: 300), (timer) {});
      },
      onLongPressEnd: (e) {
        print("长按结束");
      },
      child: Container(
        width: 160.w,
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
}
