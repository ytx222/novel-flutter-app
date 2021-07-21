import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:novel_app/pages/reader/menu/reader_menu_chapter_list.dart';
import 'package:novel_app/pages/reader/menu/reader_menu_color_setting.dart';
import 'package:novel_app/pages/reader/menu/reader_menu_font_setting.dart';
import 'package:novel_app/pages/reader/menu/reader_menu_layout_setting.dart';
import 'package:novel_app/pages/reader/menu/reader_menu_setting_list.dart';
import 'package:novel_app/pages/reader/menu/reader_menu_turn_animation_setting.dart';
import 'package:novel_app/provider/books_model.dart';
import 'package:novel_app/provider/reader_data_model.dart';
import 'package:novel_app/util/native_api.dart';
import 'package:novel_app/util/util.dart';
import 'package:novel_app/util/utils_screen.dart';
import 'package:provider/provider.dart';

import 'package:novel_app/util/ytx_ScreenUtil.dart';

/// 保存当前实例
ReaderMenuState? _state;

/// 单击后弹出的菜单
class ReaderMenu extends StatefulWidget {
  const ReaderMenu({Key? key}) : super(key: key);

  static void show() {
    _state?.show();
  }

  static void hide() {
    _state?.hide();
  }

  static void setShowType(MenuShowType type) {
    _state?.setShowType(type);
  }

  static MenuShowType? getMenuShowType() => _state?.showType;

  // ReaderMenu._() : super(key: menuKey);
  // static ReaderMenu obj;
  // static ReaderMenu init() {
  //   if (obj == null) {
  //     obj = new ReaderMenu._();
  //   }
  //   return obj;
  // }

  @override
  ReaderMenuState createState() {
    _state = ReaderMenuState();
    return _state!;
  }
}

/// 菜单,显示类型
enum MenuShowType {
  /// 隐藏
  hide,

  /// 主页面
  main,

  /// 章节列表
  chapterList,

  /// 字体设置
  font,

  /// 颜色设置
  color,

  /// 布局设置
  layout,

  /// 其他设置
  setting,

  /// 听书菜单,
  hear,

  /// 翻页动画
  turnAnimation,
}

class ReaderMenuState extends State<ReaderMenu> {
  /// 显示类型,默认为主页面
  MenuShowType _showType = MenuShowType.hide;
  set showType(MenuShowType type) {
    typeChage(type);
    _showType = type;
  }

  MenuShowType get showType => _showType;

  /// tabbar高度
  double stateBarHeigth = 0;

  /// 阅读数据
  ReaderDataModel? readerData;

  /// 书架数据
  BooksModel? booksModel;

  @override
  void initState() {
    super.initState();
    print("menu initState================================================= ");
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //设置状态栏透明,用这个需要设置计时器
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    readerData = Provider.of<ReaderDataModel>(context);
    booksModel = Provider.of<BooksModel>(context);

    Widget curType;
    switch (showType) {
      case MenuShowType.main:
        curType = main();
        break;
      case MenuShowType.chapterList:
        curType = ReaderMenuChapterList();
        break;
      case MenuShowType.font:
        curType = ReaderMenuFontSetting();
        break;

      case MenuShowType.setting:
        curType = ReaderMenuSettingList();
        break;
      case MenuShowType.color:
        curType = ReaderMenuColorSetting();
        break;
      case MenuShowType.layout:
        curType = ReaderMenuLayoutSetting();
        break;
      case MenuShowType.turnAnimation:
        curType = ReaderMenuTurnAnimationSetting();
        break;

      default:
        curType = Stack(children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 400.w,
              height: 200.w,
              decoration: BoxDecoration(
                color: Color(0xFFDD0202),
                borderRadius: BorderRadius.circular(30.w),
              ),
              clipBehavior: Clip.antiAlias,
              padding: EdgeInsets.all(20.w),
              alignment: Alignment.center,
              child: Text(
                "暂不支持此类型,请期待开发,点击屏幕其他位置返回",
                style: TextStyle(
                  fontSize: 40.w,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          )
        ]);
    }
    return Visibility(
      /// 显示类型不为hide就是显示
      visible: showType != MenuShowType.hide,
      child: Positioned.fill(
        child: Container(
          child: GestureDetector(
            //当前整个widget都是可点击区域
            behavior: HitTestBehavior.opaque,
            // 拦截这些事件,这里绑定了之后就不会继续传播了
            onTapDown: (e) {},
            onPanDown: (e) {},
            onPanStart: (e) {},
            onPanUpdate: (e) {},
            onPanEnd: (e) {},
            // 点击空白区域关闭菜单
            onTapUp: (e) {
              print("menu--onTapUp");
              hide();
            },
            child: GestureDetector(
              // 这里拦截弹起事件,防止点击标题等区域关闭菜单
              onTapUp: (e) {},
              child: curType,
            ),
          ),
        ),
      ),
    );
  }

  // 主要区域,不拆分是因为其中用到了 stateBarHeigth ,懒得拆了
  Widget main() {
    return Stack(
      children: [
        Positioned.fill(
          bottom: null,
          child: Container(
            color: Color(0xFF3F3F3F),
            padding: EdgeInsets.only(
              top: stateBarHeigth,
              left: 10.w,
              right: 10.w,
            ),
            height: 100.w + stateBarHeigth,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  // color: Color(0xFF522121),
                  child: _btn(
                    const IconData(0xe60b, fontFamily: "iconfont"),
                    iconSize: 50.w,
                    onPressed: () {
                      print("跳转===========");
                      // 先保存
                      booksModel!.saveReaderRecord(readerData!);

                      // 然后删除readerData的数据
                      readerData!.reset();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/bookrack',
                        (route) => false,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    // 72.w 106   34
                    // 文字布局有bug?,反正这里莫名多了一些间距,我自己调好了
                    margin: EdgeInsets.only(
                      // top: 17.w,
                      top: 4.w,
                      left: 20.w,
                    ),
                    child: Text(
                      readerData?.book?.name ?? '加载中',
                      style: TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontSize: 36.w,
                        height: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      strutStyle: StrutStyle(
                        height: 1,
                      ),
                    ),
                  ),
                ),
                _btn(
                  const IconData(0xe60c, fontFamily: "iconfont"),
                  iconSize: 46.w,
                  onPressed: () {
                    print("听书");
                  },
                ),
                _btn(
                  const IconData(0xe687, fontFamily: "iconfont"),
                  iconSize: 40.w,
                  onPressed: () {
                    print("选项");
                  },
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          top: null,
          child: Container(
            color: Color(0xFF3F3F3F),
            height: 300.w,
            child: btnsBox(),
          ),
        ),
      ],
    );
  }

  // 菜单-main,下面的区域,即主要部分
  Widget btnsBox() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 30.w),
      child: Column(
        children: [
          Container(
            height: 100.w,
            // color: Color(0xFFFFFFFF),
            child: Row(
              children: [
                _toggleChapterBtn(
                  text: "上一章",
                  onPressed: () {
                    print("上一章");
                    var _is = readerData!.prevChapter(false);
                    if (!_is) {
                      NovelUtil.msg("没有上一章");
                    }
                  },
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      readerData?.chapter?.name ?? '加载中',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 32.w,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                _toggleChapterBtn(
                  text: "下一章",
                  onPressed: () {
                    print("下一章");
                    var _is = readerData!.nextChapter();
                    if (!_is) {
                      NovelUtil.msg("没有下一章");
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: Row(
                children: [
                  Expanded(
                    child: _btn(
                      const IconData(0xe615, fontFamily: "iconfont"),
                      size: 17.vw,
                      text: "章节",
                      onPressed: () {
                        setState(() => showType = MenuShowType.chapterList);
                      },
                    ),
                  ),
                  Expanded(
                    child: _btn(
                      const IconData(0xe61d, fontFamily: "iconfont"),
                      size: 17.vw,
                      text: "字体",
                      onPressed: () {
                        setState(() => showType = MenuShowType.font);
                      },
                    ),
                  ),
                  Expanded(
                    child: _btn(
                      const IconData(0xe6b9, fontFamily: "iconfont"),
                      size: 17.vw,
                      text: "横屏",
                      onPressed: () {
                        print("横屏");
                        NovelUtil.msg('暂不支持');
                      },
                    ),
                  ),
                  Expanded(
                    child: _btn(
                      const IconData(0xe67a, fontFamily: "iconfont"),
                      size: 17.vw,
                      text: "设置",
                      onPressed: () {
                        setState(() => showType = MenuShowType.setting);
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _btn(
    IconData iconData, {
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
                  iconData,
                  // IconData(codePoint, fontFamily: "iconfont"),
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

  Widget _toggleChapterBtn({
    required VoidCallback onPressed,
    required String text,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(Color(0x22FFFFFF)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 30.w,
          color: Color(0xFFFFFFFF),
        ),
      ),
    );
  }

  void show() {
    print("打开菜单");
    if (showType == MenuShowType.hide) {
      // 必须先设置样式,后显示,才能显示出正确的样式

      setState(() {
        showType = MenuShowType.main;
      });
    }
  }

  void hide() {
    print("关闭菜单");
    setState(() {
      showType = MenuShowType.hide;
    });
  }

  void setShowType(MenuShowType type) {
    setState(() {
      showType = type;
    });
  }

  void initStateBarHeigth() {
    Timer.periodic(Duration(milliseconds: 3), (t) {
      var h = ScreenSizeUtil.stateBarHeigth;
      if (h > 0) {
        setState(() {
          stateBarHeigth = h;
        });
        t.cancel();
      }
    });
  }

  /// 显示类型变化时被自动调用
  /// 先写了,可能有用
  /// 将来可能将show和hide的部分逻辑挪过来
  void typeChage(MenuShowType type) {
    print(
        "menu typeChage ${type}================================================= ");

    /// 如果状态栏高度没有初始化,则初始化状态栏高度
    if (stateBarHeigth == 0.0) initStateBarHeigth();

    /// 各类型逻辑
    if (type == MenuShowType.hide) {
      // 拦截音量键
      NativeApi.setVolumeIntercept(true);
    } else if (type == MenuShowType.main) {
      // 停止拦截音量键
      NativeApi.setVolumeIntercept(false);
      // 显示系统状态栏
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
      ));
      Timer.run(() =>
          SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values));
    } else if (type == MenuShowType.chapterList) {}

    /// 需要隐藏状态栏的
    if (type == MenuShowType.chapterList ||
            type == MenuShowType.hide ||
            type == MenuShowType.font ||
            type == MenuShowType.setting ||
            type == MenuShowType.color // 虽然不能直接访问color,但也加上
        ) {
      // 隐藏状态栏
      SystemChrome.setEnabledSystemUIOverlays([]);
    }
  }
}
