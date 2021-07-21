import 'package:flutter/material.dart';
import 'package:novel_app/pages/reader/animation/bese_animation_page.dart';
import 'package:novel_app/pages/reader/widget/reader_gesture_discern.dart';
import 'package:novel_app/pages/reader/widget/reader_page_container.dart';
import 'package:novel_app/pages/reader/widget/reader_page_item.dart';
import 'package:novel_app/provider/reader_data_model.dart';
import 'package:novel_app/util/utils_screen.dart';
import 'package:provider/provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:novel_app/util/ytx_ScreenUtil.dart';

class HorizontalTurnAnimationPage extends BaseAnimationPage {
  HorizontalTurnAnimationPage({Key? key}) : super(key: key);

  /// 缓存state,确定BaseAnimationPage的state是唯一的
  static late BaseAnimationPageState state;

  /// 初始化state,会调用自身的initState获取state并赋值给自己
  @override
  BaseAnimationPageState createState() {
    var _state = HorizontalTurnAnimationPageState();
    state = _state;
    return _state;
  }
}

class HorizontalTurnAnimationPageState extends BaseAnimationPageState {
  /// 初始化
  HorizontalTurnAnimationPageState();

  /// 当前正在进行的翻页的类型,上一页,下一页,无
  PageChageType changeType = PageChageType.none;

  /// 当前页
  Widget curPageWidget = Container();

  /// 上一页
  Widget prevPageWidget = Container();

  /// 下一页
  Widget nextPageWidget = Container();

  /// 当前章节和当前页,用于自动维护页面Widget的更新
  int curChapter = -1;

  /// 当前章节和当前页,用于自动维护页面Widget的更新
  int curPage = -1;

  /// 当前是否在动画中
  bool isAnimation = false;

  /// 动画结束后要跳转的页面,当前支持 1下一页  -1上一页
  int newPageNum = 0;

  /// 用于检查性能
  int frames = 0;

  @override
  void initState() {
    super.initState();
    controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        animationEnd(status);
      }
    });
    // controller!.addListener(() {
    //   // frames++;
    // });
  }

  /// 重新初始化页面
  void initPage() {
    print("initPage============");
    curPage = readerData!.page;
    curChapter = readerData!.chapterIndex;
    curPageWidget = ReaderPageItem(
      page: readerData!.curPage,
      key: UniqueKey(),
    );

    prevPageWidget = ReaderPageItem(
      page: readerData!.prevPage,
      key: UniqueKey(),
    );

    nextPageWidget = ReaderPageItem(
      page: readerData!.nextPage,
      key: UniqueKey(),
    );
  }

  /// 检查page是否需要更新,如果需要,则更新
  void checkPageUpdate() {
    var page = readerData!.page;
    // 先判断,如果页码不匹配,则重新初始化页面
    if (curPage != page) {
      initPage();
    } else if (curChapter != readerData!.chapterIndex) {
      // 如果页码相同,章节不相同,则是通过上一章下一章执行的,也重新初始化页面
      // FIXME:这种情况应该有特殊逻辑?
      initPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    readerData ??= Provider.of<ReaderDataModel>(context);
    throw new ErrorDescription('HorizontalTurnAnimationPageState的子类需要重写build');
  }

  @override
  bool onTap(ReaderGestureData data) {
    controller?.reset();
    // 先执行
    var n = (data.start.dx / screenSize.width * 3).floor();
    // 点击中间区域,则打开菜单
    if (n == 1) {
      return false;
    }
    // 点击左右则
    if (n == 2) {
      nextPage();
    } else {
      prevPage();
    }
    // n = n - 1;
    // ReaderPageContainer.globalKey?.currentState?.pageChange(n);
    return true;
  }

  @override
  void onMove(ReaderGestureData data) {
    if (isAnimation) {
      resetAnimation();
    }
  }

  @override
  void onMoveEnd(ReaderGestureData data) {
    if (data.startDirectionsH != data.endDirectionsH ||
        data.startDirectionsH == null) {
      startAnimation(changeType == PageChageType.next);
      return;
    }

    // FIXME: 补间动画
    if (data.endDirectionsH == GestureMoveDirection.left) {
      newPageNum = 1;
      // ReaderPageContainer.globalKey?.currentState?.pageChange(1);
    } else {
      newPageNum = -1;
      // ReaderPageContainer.globalKey?.currentState?.pageChange(-1);
    }
    startAnimation(changeType != PageChageType.next);
  }

  /// 开始执行动画
  void startAnimation([bool reverse = false]) {
    isAnimation = true;
    frames = 0;
  }

  void resetAnimation() {
    print('resetAnimation');
    controller?.reset();
    frames = 0;
  }

  /// 动画结束的回调
  /// [status] 触发事件的状态,有结束(正向运转完成)和未开始(反向运转完成) 两种
  void animationEnd(AnimationStatus status) {
    isAnimation = false;

    /// 翻页状态设置为无
    changeType = PageChageType.none;

    /// 执行翻页操作
    if (newPageNum != 0) {
      ReaderPageContainer.globalKey?.currentState?.pageChange(newPageNum);
    }
    newPageNum = 0;

    /// 重新build,这个还是子类调用吧
    // setState(() {});
  }

  @override
  void nextPage() {
    controller?.reset();
    newPageNum = 1;
    changeType = PageChageType.next;
    startAnimation();
  }

  @override
  void prevPage() {
    controller?.reset();
    newPageNum = -1;
    changeType = PageChageType.prev;
    startAnimation(true);
  }
}
