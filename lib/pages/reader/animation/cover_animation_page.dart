import 'package:flutter/material.dart';
import 'package:novel_app/pages/reader/animation/bese_animation_page.dart';
import 'package:novel_app/pages/reader/widget/reader_gesture_discern.dart';
import 'package:novel_app/provider/reader_data_model.dart';
import 'package:provider/provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'horizontal_turn_animation_page.dart';

class CoverAnimationPage extends HorizontalTurnAnimationPage {
  CoverAnimationPage({Key? key}) : super(key: key);

  /// 缓存state,确定BaseAnimationPage的state是唯一的
  static late BaseAnimationPageState state;

  /// 初始化state,会调用自身的initState获取state并赋值给自己
  @override
  BaseAnimationPageState createState() {
    var _state = CoverAnimationPageState();
    state = _state;
    return _state;
  }
}

class CoverAnimationPageState extends HorizontalTurnAnimationPageState {
  /// 初始化
  CoverAnimationPageState();

  /// 偏移距离
  double offset = 0;

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    readerData ??= Provider.of<ReaderDataModel>(context);

    checkPageUpdate();

    return Container(
      width: screenSize.width,
      height: screenSize.height,
      color: Color(0xFF212A47),
      child: Stack(
        // clipBehavior: Clip.hardEdge,
        children: [
          // 默认,none 显示当前页
          if (changeType == PageChageType.none) subContainer(curPageWidget),
          // supContainer(curPageWidget),
          // 下一页时,渲染两页,当前页和下一页,下一页在下层
          if (changeType == PageChageType.next) subContainer(nextPageWidget),
          if (changeType == PageChageType.next) supContainer(curPageWidget),
          // 上一页时,渲染上一页和当前页,当前页在下层
          if (changeType == PageChageType.prev) subContainer(curPageWidget),
          if (changeType == PageChageType.prev) supContainer(prevPageWidget),
        ],
      ),
    );
  }

  Widget subContainer(Widget child) {
    return Container(
      width: screenSize.width,
      height: screenSize.height,
      child: child,
    );
  }

  Animation<Offset>? _offsetAnimation;
  Animation<RelativeRect>? animation2;

  Widget supContainer(Widget child) {
    if (!isAnimation) {
      return Positioned(
        right: offset,
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x99000000),
                spreadRadius: 0,
                blurRadius: 30.w,
              )
            ],
          ),
          child: child,
        ),
      );
    }


    PositionedTransition c = PositionedTransition(
      rect: animation2!,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x99000000),
              spreadRadius: 0,
              blurRadius: 30.w,
            )
          ],
          color: Color(0xFF0CDD05),
        ),
        child: child,
      ),
    );
    return c;
  }

  @override
  bool onTap(ReaderGestureData data) {
    return super.onTap(data);
  }

  @override
  void onMove(ReaderGestureData data) {
    if (isAnimation) {
      resetAnimation();
    }

    if (data.startDirectionsH == GestureMoveDirection.left) {
      changeType = PageChageType.next;
      var newRight = data.start.dx - data.last.dx;
      if (newRight < 0) {
        offset = 0;
      } else {
        offset = newRight;
      }
    } else if (data.startDirectionsH == GestureMoveDirection.rigth) {
      changeType = PageChageType.prev;
      offset = screenSize.width - data.last.dx;
    }
    print(isAnimation);
    print(offset);

    setState(() {});
  }

  @override
  void onMoveEnd(ReaderGestureData data) {
    super.onMoveEnd(data);
  }

  /// 开始执行动画
  /// 采用计算应该执行的时间的+从当前offset开始,可以避免曲线造成进度不匹配
  void startAnimation([bool reverse = false]) {
    var start = offset * -1;
    var end = -360.0 - 30.w;// 30.w是阴影距离,如果加上阴影距离,阴影消失的就不会太明显
    var restTime = offset / screenSize.width;
    if (reverse) {
      end = 0;
    } else {
      restTime = 1 - restTime;
    }

    animation2 = RelativeRectTween(
      begin: RelativeRect.fromSize(Rect.fromLTWH(start, 0, 0, 0), Size.zero),
      end: RelativeRect.fromSize(Rect.fromLTWH(end, 0, 0, 0), Size.zero),
    ).animate(CurvedAnimation(
      parent: controller!,
      // linear decelerate ease easeOut easeOutSine
      curve: Curves.easeInOut,
    ));
    controller!.duration = baseDuration * restTime;

    // 不能将值设置成0,否则会触发结束事件
    controller?.value = 0.0000000001;
    controller?.forward();
    isAnimation = true;

    offset = 0;

    setState(() {});
  }

  /// 动画结束的回调
  /// [status] 触发事件的状态,有结束(正向运转完成)和未开始(反向运转完成) 两种
  void animationEnd(AnimationStatus status) {
    print("animationEnd============11");
    print("animationEnd============22");
    print("animationEnd============33");
    print("animationEnd============44");
    print("animationEnd============55");
    print("animationEnd============66");
    super.animationEnd(status);
    print(isAnimation);

    /// 重新build
    setState(() {});
  }

  @override
  void nextPage() {
    offset = 1;
    super.nextPage();
  }

  @override
  void prevPage() {
    offset = screenSize.width - 1;
    // offset = 0;
    super.prevPage();
  }
}
