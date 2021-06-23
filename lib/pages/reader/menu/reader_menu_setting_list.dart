import 'package:flutter/material.dart';
import 'package:novel_app/pages/reader/menu/reader_menu.dart';
import 'package:novel_app/pages/reader/menu/reader_menu_container.dart';

import 'package:novel_app/util/util.dart';
import 'package:novel_app/util/ytx_ScreenUtil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ReaderMenuSettingList extends StatefulWidget {
  ReaderMenuSettingList({Key? key}) : super(key: key);

  @override
  _ReaderMenuSettingListState createState() => _ReaderMenuSettingListState();
}

class _ReaderMenuSettingListState extends State<ReaderMenuSettingList> {
  @override
  Widget build(BuildContext context) {
    var _default = Expanded(
      child: _btn(0xe7eb, size: 17.vw, text: "其他设置", onPressed: () {
        ReaderMenu.setShowType(MenuShowType.font);
      }),
    );
    return Container(
      child: ReaderMenuContainer(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _btn(0xe61d, size: 17.vw, text: "字体", onPressed: () {
                    ReaderMenu.setShowType(MenuShowType.font);
                  }),
                ),
                Expanded(
                  child: _btn(0xe61c, size: 17.vw, text: "颜色", onPressed: () {
                    ReaderMenu.setShowType(MenuShowType.color);
                  }),
                ),
                Expanded(
                  child: _btn(0xe61c, size: 17.vw, text: "布局", onPressed: () {
                    ReaderMenu.setShowType(MenuShowType.layout);
                  }),
                ),
                Expanded(
                  child: _btn(0xe7eb, size: 17.vw, text: "横屏", onPressed: () {
                    print("横屏");
                    NovelUtil.msg('暂不支持');
                  }),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _btn(0xe613, size: 17.vw, text: "翻页动画", onPressed: () {
                    ReaderMenu.setShowType(MenuShowType.turnAnimation);
                  }),
                ),
                _default,
                _default,
                _default,
              ],
            ),
            Row(
              children: [
                _default,
                _default,
                _default,
                _default,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(
    int codePoint, {
    VoidCallback? onPressed,
    String? text,
    double size = 50,
    double iconSize = 24,
  }) {
    return Center(
      child: ClipOval(
        child: Container(
          width: size,
          height: size,
          child: TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                EdgeInsets.all(0),
              ),
              overlayColor: MaterialStateProperty.all<Color>(Color(0x22FFFFFF)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  IconData(codePoint, fontFamily: "iconfont"),
                  color: Color(0xFFDDDDDD),
                  size: iconSize,
                ),
                if (text != null) SizedBox(height: 10.w),
                if (text != null)
                  Text(
                    text,
                    style: TextStyle(fontSize: 26.w, color: Color(0xFFDDDDDD)),
                  )
              ],
            ),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
