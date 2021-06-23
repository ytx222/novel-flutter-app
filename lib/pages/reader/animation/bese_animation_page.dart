import 'package:flutter/material.dart';
import 'package:novel_app/pages/reader/widget/reader_gesture_discern.dart';
import 'package:novel_app/pages/reader/widget/reader_page_item.dart';
import 'package:novel_app/provider/reader_data_model.dart';
import 'package:novel_app/util/utils_screen.dart';
import 'package:provider/provider.dart';

/// 动画实现的基类
/// 定义了各种动画实现所需要的最基本的api等
// abstract class BaseAnimationPage mixin SingleTickerProviderStateMixin  with SingleTickerProviderStateMixin{
//   BaseAnimationPage();
//   AnimationController controller =AnimationController(vsync: this);
// }

/// 页面切换的类型,
enum PageChageType {
  /// 下一页
  next,

  /// 上一页
  prev,

  /// 没有
  none
}

abstract class BaseAnimationPage extends StatefulWidget {
  BaseAnimationPage({Key? key}) : super(key: key);

  /// 缓存state,确定BaseAnimationPage的state是唯一的
  // static late BaseAnimationPageState state;

  /// 初始化state,会调用自身的initState获取state并赋值给自己
  // @override
  //  BaseAnimationPageState createState()
  //  {
  //   var _state = BaseAnimationPageState();
  //   state = _state;
  //   return _state;
  // }
}

abstract class BaseAnimationPageState extends State<BaseAnimationPage>
    with SingleTickerProviderStateMixin {
  /// 当前书对象,逻辑大多数都在这里,书对象就是用来初始化这个对象的
  ReaderDataModel? readerData;

  AnimationController? controller;

  /// 屏幕大小
  // Offset screenSize = Offset(
  //   ScreenSizeUtil.getScreenWidth(),
  //   ScreenSizeUtil.getScreenHeight(),
  // );

  /// 屏幕大小
  Size screenSize = Size(
    ScreenSizeUtil.getScreenWidth(),
    ScreenSizeUtil.getScreenHeight(),
  );

  /// 完整的动画应该持续的时间
  Duration baseDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: baseDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  /// 在按下后没有移动时触发,这个给个默认值吧
  bool onTap(ReaderGestureData data) {
    return false;
  }

  /// 按下后移动中
  void onMove(ReaderGestureData data);

  /// 移动后,手指弹起
  void onMoveEnd(ReaderGestureData data);

  /// 页面变化事件
  // void onPageChange(int oldPage, int newPage) {}

  /// 章节变化事件
  // void onChapterChange(int oldPage, int newPage) {}

  /// 带动画的执行翻页
  void nextPage();

  /// 带动画的执行,翻页
  void prevPage();
}
