import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:novel_app/class/chapter.dart';
import 'package:novel_app/class/scroll-bar.dart';
import 'package:novel_app/pages/reader/menu/reader_menu.dart';
import 'package:novel_app/provider/reader_data_model.dart';
import 'package:novel_app/provider/reader_setting_model.dart';
import 'package:provider/provider.dart';
import 'package:novel_app/util/ytx_ScreenUtil.dart';

/// 菜单中的章节列表
class ReaderMenuChapterList extends StatefulWidget {
  ReaderMenuChapterList({Key? key}) : super(key: key);

  @override
  _ReaderMenuChapterListState createState() => _ReaderMenuChapterListState();
}

class _ReaderMenuChapterListState extends State<ReaderMenuChapterList> {
  late ReaderSettingModel setting;
  @override
  Widget build(BuildContext context) {
    var readerData = Provider.of<ReaderDataModel>(context);
    setting = Provider.of<ReaderSettingModel>(context);
    return GestureDetector(
      onTapUp: (e) {
        ReaderMenu.hide();
      },
      child: Container(
        color: Color(0x66000000),
        child: Stack(children: [
          Positioned.fill(
            right: null,
            child: GestureDetector(
              onTapUp: (e) {},
              child: Container(
                color: setting.backgroundColor,
                width: 600.w,
                // 顶部安全区,
                padding: EdgeInsets.only(
                  top: setting.headerTopOffset,
                  left: setting.contentHorizontalPadding,
                  right: setting.contentHorizontalPadding,
                ),
                child: Column(
                  children: [
                    /// 留100间距
                    SizedBox(height: 100.w),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(10.w),
                      height: 70.w,
                      margin: EdgeInsets.symmetric(vertical: 10.w),
                      child: Text(
                        readerData.book?.name ?? '默认书名',
                        style: TextStyle(
                          fontSize: 36.w,
                          color: setting.color,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 80.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal:
                              BorderSide(color: Color(0x13000000), width: 1.w),
                        ),
                      ),
                      child: Text(
                        "章节列表",
                        style: TextStyle(
                          fontSize: 30.w,
                          color: setting.color,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 600.w,
                        child: _list(readerData),
                      ),
                    ),

                    /// 留100间距
                    SizedBox(height: 100.w),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  ScrollController controller = ScrollController();

  Widget _list(ReaderDataModel readerData) {
    var list = readerData.chapterList;
    // 计算初始高度
    var offset = readerData.chapterIndex * 100.w;
    print("==_list_list_li_list_list");
    var h = 100.vh - setting.headerTopOffset - 100.w - 80.w - 80.w - 100.w;

    /// 不知道这10的误差是哪里来的,
    h -= 10.w;
    // 保险起见,再次-1
    h -= 1;
    var max = list.length * 100.w - h;
    if (offset > max) {
      offset = max;
    }
    // controller.jumpTo(offset);
    print(h);
    /**
     *  var max = controller.position.maxScrollExtent;

     */
    // controller = ScrollController(initialScrollOffset: offset,keepScrollOffset: false);
    controller = ScrollController(
      initialScrollOffset: offset,
      keepScrollOffset: false,
    );

    var widget = ListView.builder(
      itemCount: list.length,
      controller: controller,
      itemBuilder: (context, index) {
        return _ChapterItem(chapter: list[index], index: index);
      },
    );

    return YtxScrollBar(
      controller: controller,
      // initOffset:offset,
      child: widget,
    );
    // return Scrollbar(
    //   child: ListView.builder(
    //     itemCount: list.length,
    //     itemBuilder: (context, index) {
    //       return _ChapterItem(chapter: list[index], index: index);
    //     },
    //   ),
    // );
  }
}

class _ChapterItem extends StatelessWidget {
  final Chapter chapter;
  final int index;

  // static const Color defaultColor = Color(0xff);
  const _ChapterItem({
    Key? key,
    required this.chapter,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool hover = false;
    var setting = Provider.of<ReaderSettingModel>(context);
    var readerData = Provider.of<ReaderDataModel>(context);
    return StatefulBuilder(
      builder: (BuildContext context, setState) {
        return GestureDetector(
          onTapDown: (e) => setState(() => hover = true),
          onTapCancel: () => setState(() => hover = false),
          onTapUp: (e) {
            setState(() => hover = false);
            ReaderMenu.hide();
            readerData.setChapter(index);
          },
          child: Container(
            alignment: Alignment.centerLeft,
            height: 100.w,
            padding: EdgeInsets.symmetric(
              vertical: 10.w,
              horizontal: 10.w,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0x13000000), width: 1.w),
              ),
              color: hover ? Color(0x18000000) : null,
            ),
            child: Text(
              chapter.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 28.w,
                color: readerData.chapterIndex == index
                    ? Color(0xFFDF6637)
                    : setting.color,
              ),
            ),
          ),
        );
      },
    );
  }
}
