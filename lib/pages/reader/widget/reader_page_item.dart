import 'package:flutter/cupertino.dart' hide Page;
import 'package:flutter/material.dart' hide Page;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:novel_app/class/page.dart';
import 'package:novel_app/class/section.dart';
import 'package:novel_app/pages/reader/menu/reader_menu.dart';
import 'package:novel_app/pages/reader/widget/reader_item_system_info.dart';
import 'package:novel_app/pages/reader/widget/reader_page_container.dart';
import 'package:novel_app/provider/reader_data_model.dart';
import 'package:novel_app/provider/reader_setting_model.dart';
import 'package:novel_app/util/native_api.dart';
import 'package:novel_app/util/split_util.dart';
import 'package:novel_app/util/util.dart';
import 'package:provider/provider.dart';
import 'package:novel_app/util/ytx_ScreenUtil.dart';

/// 阅读页中的一页
/// 需要参数,传值还是传对象??
class ReaderPageItem extends StatelessWidget {
  ReaderPageItem({
    required this.page,
    // required this.pageNum,
    // required this.title,
    Key? key,
  }) : super(key: key);
  final Page page;
  // final int pageNum;
  // final String title;

  ReaderSettingModel? setting;
  var barFontstyle = TextStyle(
    fontSize: 24.w,
    color: Color(0xFF444444),
  );

  static var hideButton = false;


  @override
  Widget build(BuildContext context) {

    print("ReaderPageItem build");
    //FIXME: 考虑将setting在其他地方统一分配好,直接使用
    // 可能不太现实
    setting = Provider.of<ReaderSettingModel>(context);
    // 初始化样式,其实不应该放在这里
    titleStyle = TextStyle(
      fontSize: setting!.titleFontSize,
      height: setting!.titleLineHeight,
    );
    barFontstyle = TextStyle(
      fontSize: 24.w,
      // color: Color(0xFF444444),
      color: setting!.color,
    );

    style = TextStyle(
      fontSize: setting!.fontSize,
      height: setting!.lineHeight,
      color: setting!.color,
    );

    return Container(
      child: Stack(
        children: [
          Container(
            // 因为这些样式每一页都要有,所以样式放在每一页上更合适
            // padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              color: setting!.backgroundColor,
            ),
            child: Column(
              children: [
                // 上下的信息栏颜色与主色相对的同时要淡一些,所以使用Opacity比较方便
                Opacity(
                  opacity: 0.7,
                  child: headerBar(page.chapter.name),
                ),
                Expanded(child: content()),
                Opacity(
                  opacity: 0.7,
                  child: footerBar(),
                ),
              ],
            ),
          ),
          // 这里可以是附加层
          // Container(color: Color(0x22612F2F)),
          testButton(
            onPressed: () async {
              // setting!.saveChange();
              // print(pageNum);
              // print(page.toJson());
              // print(style);
              // print(style.fontSize);
              var readerData =
                  Provider.of<ReaderDataModel>(context, listen: false);
              print(readerData);
            },
          ),
          testButton(
            // top: 180.w,
            left: 160.w,
            text: '调试原生专用2',
            onPressed: () {
              print("按钮被点击222");

              NativeApi.setBatteryChangeObserver(true);
            },
          ),
          testButton(
            // top: 230.w,
            left: 280.w,
            width: 60.w,
            text: '调试数据专用',
            onPressed: () {
              var readerData =
                  Provider.of<ReaderDataModel>(context, listen: false);
              // SplitUtil.isLog = true;
              var c = readerData.nextChapterData!;
              print(c);
              print(c.pages[0].sectionList[1].text);
            },
          ),

          testButton(
            top: 160.w,
            // left: 280.w,
            width: 160.w,
            text: '隐藏按钮',
            onPressed: () {
              hideButton = true;
            },
          ),
        ],
      ),
    );
  }

  Widget testButton(
      {double top = 0,
      double left = 0,
      String text = "按钮",
      double width = 0,
      double height = 0,
      double opacity = 0.5,
      VoidCallback? onPressed,
      double fontSize = 0}) {
    height = height == 0 ? 60.w : height;
    top = top == 0 ? 80.w : top;
    width = width == 0 ? 100.w : width;
    fontSize = fontSize == 0 ? 24.w : fontSize;
    left = left == 0 ? 50.w : left;
    return Positioned(
      top: hideButton ? -99.w : top,
      left: left,
      width: width,
      height: height,
      child: Opacity(
        opacity: 1,
        child: ElevatedButton(
          style: ButtonStyle(
            padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(
              EdgeInsets.all(0),
            ),
            backgroundColor: ButtonStyleButton.allOrNull<Color>(
              Color(
                (0xFF * opacity).toInt() * 0x1000000,
              ),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.white,
              // background: Paint()..color=Colors.black
            ),
          ),
        ),
      ),
    );
  }

// 中间的内容
  Widget content() {
    var list = <Widget>[];
    list.addAll(page.sectionList.map((e) {
      if (e.isTitle) return contentTitle(e.text);
      return contentSection(e);
    }));
    return Padding(
      padding: EdgeInsets.fromLTRB(
          setting!.contentHorizontalPadding,
          setting!.contentToplPadding,
          setting!.contentHorizontalPadding,
          setting!.contentBottomlPadding),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          // margin:
          // color: Color(0xFFFFFFFF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list,
          ),
        ),
      ),
    );
  }

  static TextStyle? titleStyle;
  static TextStyle? style;

  Widget contentTitle(String title) {
    return Container(
      width: 100.vw,
      child: Text(
        title.trim(),
        textAlign: TextAlign.center,
        style: titleStyle,
      ),
    );
  }

  Widget contentSection(Section section) {
    var txt = section.text;
    if (section.isStart) {
      txt = setting!.indentString + txt;
    }
    var text = Text(
      txt,
      textAlign: TextAlign.left,
      style: style,
      // strutStyle:  StrutStyle(forceStrutHeight: true, height: 1, leading: 0),
    );
    return Container(
      // color: Color(0xFF198B3F),
      margin:
          section.isSpace ? EdgeInsets.only(top: setting!.sectionSpace) : null,
      child: text,
    );
  }

  /// 标题栏
  Widget headerBar(String text) {
    return Container(
      width: 100.vw - setting!.headerRightOffset,
      height: 80.w,
      // 顶部安全区,
      margin: EdgeInsets.only(top: setting!.headerTopOffset),
      // 右侧安全区
      padding: EdgeInsets.only(
        right: setting!.headerRightOffset,
        left: setting!.headerLeftOffset,
      ),
      alignment: Alignment.centerRight,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: barFontstyle,
      ),
    );
  }

  /// 底部信息栏
  Widget footerBar() {
    return Container(
      width: 100.vw,
      height: 80.w,
      // 顶部安全区,
      margin: EdgeInsets.only(bottom: setting!.footerBottomOffset),
      //左右安全区
      padding:
          EdgeInsets.symmetric(horizontal: setting!.footerHorizontalOffset),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${page.index + 1}/${page.chapter.pages.length}",
            style: barFontstyle,
          ),
          ReaderItemSystemInfo(style: barFontstyle)
        ],
      ),
    );
  }
}
