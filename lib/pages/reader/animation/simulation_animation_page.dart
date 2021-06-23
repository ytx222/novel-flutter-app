import 'dart:math';

import 'package:flutter/material.dart';
import 'package:novel_app/pages/reader/animation/bese_animation_page.dart';
import 'package:novel_app/pages/reader/widget/reader_gesture_discern.dart';
import 'package:novel_app/provider/reader_data_model.dart';
import 'package:novel_app/util/utils_screen.dart';
import 'package:provider/provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'horizontal_turn_animation_page.dart';

/// 动画对应的点
enum Anchor {
  /// 屏幕右上角
  top,

  /// 屏幕右边中心
  center,

  /// 屏幕右下角
  bottom,
}

class SimulationAnimationPage extends HorizontalTurnAnimationPage {
  SimulationAnimationPage({Key? key}) : super(key: key);

  /// 缓存state,确定BaseAnimationPage的state是唯一的
  static late BaseAnimationPageState state;

  /// 初始化state,会调用自身的initState获取state并赋值给自己
  @override
  BaseAnimationPageState createState() {
    var _state = SimulationAnimationPageState();
    state = _state;
    return _state;
  }
}

class SimulationAnimationPageState extends HorizontalTurnAnimationPageState {
  /// 初始化
  SimulationAnimationPageState();

  /// 动画对应起始点
  Anchor anchor = Anchor.center;
  Offset get anchorOffset {
    double y = 0;
    if (anchor == Anchor.center) {
      y = screenSize.height / 2;
    } else if (anchor == Anchor.bottom) {
      y = screenSize.height;
    }
    return Offset(screenSize.width, y);
  }

  /// 当前点
  Offset cur = Offset.zero;

  /// 翻转中轴上边的点
  Offset topDot = Offset.zero;

  ///  翻转中轴下边的点
  Offset bottomDot = Offset.zero;

  // /// 当前点-x
  // double x = 0;

  // /// 当前点-y
  // double y = 0;

  @override
  void initState() {
    super.initState();
  }

  /// 屏幕大小
  Size halfSize = Size(
    ScreenSizeUtil.getScreenWidth() / 2,
    ScreenSizeUtil.getScreenHeight() / 2,
  );

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
          if (changeType == PageChageType.none) defaultContainer(curPageWidget),
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

  Widget defaultContainer(Widget child) {
    // return child;
    // Vector3()
    Matrix4 m;
    // m = Matrix4.rotationY(pi);
    m = Matrix4.translationValues(0, 0, 0);
    // m.rotateY(3);
    // m.leftTranslate(0);
    // m.rotateY(-1.8);

    /** 这个可以将其颠倒 */
    // Matrix4 m2;
    // m2 = Matrix4.translationValues(screenSize.width, 0, 0);
    // m2.rotateY(pi);

    return Positioned.fill(
      child: Stack(
        children: [
          Center(
            child: ClipPath(
              // clipper: LineClip(),
              child: Transform(
                transform: m,
                child: Container(
                  width: screenSize.width,
                  height: screenSize.height,
                  // width: halfSize.width,
                  // height: halfSize.height,
                  child: child,
                ),
              ),
            ),
          ),
          // Center(
          //   child: Transform(
          //     transform: m2,
          //     child: Container(
          //       width: screenSize.width,
          //       height: screenSize.height,
          //       child: child,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget subContainer(Widget child) {
    return Container(
      color: Color(0xFFFFFFFF),
    );
    return Container(
      width: screenSize.width,
      height: screenSize.height,
      child: child,
    );
  }

  Widget supContainer(Widget child) {
    Matrix4 m2 = Matrix4.translationValues(screenSize.width, 0, 0);
    m2.rotateY(pi);

    double _deg = 0;
    double? supTop = null;
    double? supBottom = null;
    Alignment alignment;
    if (anchor == Anchor.top) {
      supTop = 0;
      alignment = Alignment.topRight;
      _deg = deg2 * 2 - pi;
    } else if (anchor == Anchor.bottom) {
      supBottom = 0;
      alignment = Alignment.bottomRight;
      _deg = pi - deg2 * 2;
    } else {
      alignment = Alignment.centerRight;
    }
    Matrix4 m1 = Matrix4.rotationZ(_deg);

    if (!isAnimation) {
      //
      return Positioned.fill(
        child: Stack(
          children: [
            subClipPage(topDot: topDot, bottomDot: bottomDot, page: child),
            // 定位
            supClipPage(
              topDot: topDot,
              bottomDot: bottomDot,
              supTop: supTop,
              supBottom: supBottom,
              m1: m1,
              m2: m2,
              deg: _deg,
              alignment: alignment,
              page: child,
            ),
            Center(
              child: Container(
                color: Color(0xEE5EEE32),
                padding: EdgeInsets.all(10),
                child: Text("$cur"),
              ),
            ),
            testDot(topDot),
            testDot(bottomDot),
            testDot(cur),
            testDot(center, Color(0xFFFF00F2)),
          ],
        ),
      );
    }

    var start = cur;
    var end = Offset(0, screenSize.height);

    Tween(begin: start, end: end).animate(controller!);

    return AnimatedBuilder(
      animation: controller!,
      builder: (BuildContext context, Widget? child2) {
        var v = controller!.value;
        var diff = animationEndDot - animationStartDot;
        var newCur = animationStartDot + diff * v;

        if (anchor == Anchor.top) {
          _deg = deg2 * 2 - pi;
        } else if (anchor == Anchor.bottom) {
          _deg = pi - deg2 * 2;
        }
        m1 = Matrix4.rotationZ(_deg);

        print(newCur);
        calcLine(newCur);

        return Positioned.fill(
          child: Stack(
            children: [
              subClipPage(topDot: topDot, bottomDot: bottomDot, page: child),
              // 定位
              supClipPage(
                topDot: topDot,
                bottomDot: bottomDot,
                supTop: supTop,
                supBottom: supBottom,
                m1: m1,
                m2: m2,
                deg: _deg,
                alignment: alignment,
                page: child,
              ),
              Center(
                child: Container(
                  color: Color(0xEE5EEE32),
                  padding: EdgeInsets.all(10),
                  child: Text("$cur"),
                ),
              ),
              testDot(topDot),
              testDot(bottomDot),
              testDot(cur),
              testDot(center, Color(0xFFFF00F2)),
            ],
          ),
        );
      },
    );
  }

  /// 被裁剪的页面,剩余的部分(下面的部分)
  Widget subClipPage({
    required Offset topDot,
    required Offset bottomDot,
    required Widget page,
  }) {
    return ClipPath(
      clipper: SubClip(topDot, bottomDot),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x99000000),
              spreadRadius: 0,
              blurRadius: 30.w,
            )
          ],
        ),
        child: page,
      ),
    );
  }

  /// 被裁剪的页面,被裁剪的部分(上面的部分)
  Widget supClipPage({
    required Offset topDot,
    required Offset bottomDot,
    double? supTop,
    double? supBottom,
    required Matrix4 m1,
    required Matrix4 m2,
    required double deg,
    required Alignment alignment,
    required Widget page,
  }) {
    // return Container();
    return Positioned(
      top: supTop,
      bottom: supBottom,
      right: clipRestSize.width,
      child: Transform(
        // 负责旋转
        transform: m1,
        alignment: alignment,
        child: Container(
          // 控制大小,内部包含Stack,然后溢出隐藏
          width: clipRestSize.width,
          height: clipRestSize.height,
          decoration: BoxDecoration(),
          // clipBehavior: Clip.antiAlias,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: supTop,
                bottom: supBottom,
                left: 0,
                child: Container(
                  width: screenSize.width,
                  height: screenSize.height,
                  // color: Color(0x66000000),
                  child: ClipPath(
                    clipper: SupClip(topDot, bottomDot),
                    child: Transform(
                      transform: m2,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x99000000),
                              spreadRadius: 0,
                              blurRadius: 30.w,
                            )
                          ],
                        ),
                        child: page,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget testDot(Offset offset, [Color c = const Color(0xFFFF0000)]) {
    var size = 40.w;
    // return Container();
    return Positioned(
      left: offset.dx - size * 1.5,
      top: offset.dy - size * 1.5,
      child: Opacity(
        opacity: 0.6,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF000000),
            borderRadius: BorderRadius.circular(size * 2),
          ),
          padding: EdgeInsets.all(size),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(size),
            ),
          ),
        ),
      ),
    );
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
    // 初始化操作
    if (changeType == PageChageType.none) {
      // 初始化开始锚点
      // 中间40%,计算为中间,上下30%计算为上下

      // 判断方向
      if (data.startDirectionsH == GestureMoveDirection.left) {
        changeType = PageChageType.next;
        // 只有下一页时才有多个锚点,
        var y = data.start.dy;
        var v = y / screenSize.height;
        if (v < 0.3) {
          anchor = Anchor.top;
        } else if (v > 0.7) {
          anchor = Anchor.bottom;
        } else {
          anchor = Anchor.center;
        }
      } else if (data.startDirectionsH == GestureMoveDirection.rigth) {
        changeType = PageChageType.prev;
        anchor = Anchor.center;
      }
    }

    cur = data.last;
    try {
      calcLine(cur);
    } catch (e) {
      print("发送异常");
      print(e);
    }

    setState(() {});
  }

  Offset center = Offset.zero;
  double deg2 = 0;
  Size clipRestSize = Size.zero;

  /// 根据当前点和初始锚点,计算出翻转中轴
  void calcLine(Offset cur) {
    /**
     * 对于锚点在中间
     *  计算十分简单,因为锚点在中间时是垂直翻页,只需要一个点的位置就行了(left)
     *  这时候上下两点上的y=0,下的y=屏幕高度,x=left
     *  left就是中点
     *
     * 对于锚点在上下
     * 计算出当前点和锚点之间的中点
     * 然后计算出中点和锚点的距离(xie),和直角两边的两个角
     * 中点作为底边的一个点,锚点作为顶点,可以得出一个三角形.
     * 三角形的具体参数通过两个角和 xie 可以算出
     * 在锚点为下时,◢ 底边是下边 在锚点为上时◥ 底边为上边
     * 计算两个点,是斜边的两个点(这两个点都只能在屏幕的上右下三条边上)
     * 第一个点,是底边上的点,0~屏幕长度,计算时可能小于0,
     *  小于0时根据当前角度,和屏幕长度,重新计算中心点
     * 第二个点,是底边对应的顶点,可能在屏幕右边上或上边上(锚点为上时在下边),
     *  计算时先计算三角形高度是否超出屏幕高度,如果超出,这个点就在上边
     *  如果超出范围,则根据底边长度,垂直边长度和溢出长度,算出在上边上的长度
     * 本人初中数学水平,三角函数自学的,看不懂的慢慢看相信自己
     */
    var w = screenSize.width;
    var h = screenSize.height;
    // 当前位置和锚点差异的部分
    var diff = anchorOffset - cur;
    var centerMultiple = 0.5;
    // 中点,实际上不一定是50%,也可能是30%
    center = cur + diff * centerMultiple;
    if (anchor == Anchor.center) {
      topDot = Offset(center.dx, 0);
      bottomDot = Offset(center.dx, h);
      clipRestSize = Size(w - center.dx, h);
      deg2 = 0;
      return;
    } else {
      // print(center);
      var x = anchorOffset.dx - center.dx;
      var y = (anchorOffset.dy - center.dy).abs();
      var xie = sqrt(x * x + y * y);
      // deg: 切割出的三角形底边与当前点
      var deg = atan(y / x);
      deg2 = 0.5 * pi - deg;
      // var deg2 = 0.5 * pi - deg;
      // 计算底边上的点(如果是bottom,则是下边的点,top是上边的点)
      var bc = cos(deg);
      var bottom = xie / bc;

      // 如果底边长度超过屏幕长度,则根据屏幕长度和角度计算出新的 xie
      if (bottom > w) {
        bottom = w;
        // 重新计算中点
        var v = bottom * bc / xie;
        center = anchorOffset - diff * (1 - centerMultiple) * v;
        xie = bottom * bc;
      }
      double dot1Left = w - bottom;
      // 计算上边的点
      var tc = cos(deg2);
      var top = xie / tc;
      double dot2Left;
      double dot2Top;
      if (h - top > 0) {
        dot2Left = w;
        dot2Top = h - top;
      } else {
        // 超出时 没必要用三角函数了,直接用比值算吧
        var v = (top - h) / top * bottom;
        dot2Left = w - v;
        dot2Top = 0;
      }
      // topDot,bottomDot是裁剪使用的参数
      // clipWidth,clipHeight,
      if (anchor == Anchor.top) {
        topDot = Offset(dot1Left, 0);
        bottomDot = Offset(dot2Left, h - dot2Top);
      } else {
        topDot = Offset(dot2Left, dot2Top);
        bottomDot = Offset(dot1Left, h);
      }
      clipRestSize = Size(w - min(dot1Left, dot2Left), h - dot2Top);
    }
    print('========');
    // print("getClip=>  top $top, bottom:$bottom");
  }

  @override
  void onMoveEnd(ReaderGestureData data) {
    super.onMoveEnd(data);
  }

  Offset animationStartDot = Offset.zero;
  Offset animationEndDot = Offset.zero;

  /// 开始执行动画
  void startAnimation([bool reverse = false]) {
    print('startAnimation===============');
    // 不能将值设置成0,否则会触发结束事件
    animationStartDot = cur;
    if (reverse) {
      animationEndDot = Offset(screenSize.width, screenSize.height / 2);
    } else {
      animationEndDot = Offset(-screenSize.width, anchorOffset.dy);
    }
    controller?.value = 0.0000000001;
    controller?.forward();
    isAnimation = true;
    setState(() {});
    // 开始动画的代码
    // animationEnd(AnimationStatus.completed);
  }

  /// 动画结束的回调
  /// [status] 触发事件的状态,有结束(正向运转完成)和未开始(反向运转完成) 两种
  void animationEnd(AnimationStatus status) {
    super.animationEnd(status);
    setState(() {});
    // changeType = PageChageType.next;
  }

  @override
  void nextPage() {
    print("仿真动画 => nextPage");
    // offset = 1;
    super.nextPage();
  }

  @override
  void prevPage() {
    print("仿真动画 => prevPage");
    //  offset = screenSize.width - 1;
    super.prevPage();
  }
}

/// 裁剪当前页的正面
/// [top] 上边的一个点
/// [bottom] 下边的一个点
class SubClip extends CustomClipper<Path> {
  SubClip(this.top, this.bottom);
  Offset top;
  Offset bottom;

  @override
  Path getClip(Size size) {
    // top = Offset(100, 0);
    // bottom = Offset(200, size.height);
    assert(
      // 如果top在上边线上
      (top.dy == 0 && top.dx >= 0 && top.dx <= size.width) ||
          // 如果top在右边线上
          (top.dy != 0 && top.dx == size.width),
    );
    assert(
      // 如果 bottom 在下边线上
      (bottom.dy == size.height && bottom.dx >= 0 && bottom.dx <= size.width) ||
          // 如果top在右边线上
          (bottom.dy != size.height && bottom.dx == size.width),
    );

    var path = Path();

    path.lineTo(0.0, 0.0); // 初始,左上角

    if (top.dy != 0) {
      // 如果top不在最上边的边上,则添加顶点右上角
      path.lineTo(size.width, 0.0);
    }
    path.lineTo(top.dx, top.dy); // 添加top
    path.lineTo(bottom.dx, bottom.dy); // 添加top
    if (bottom.dx == size.width) {
      // 如果bottom
      path.lineTo(size.width, size.height);
    }

    path.lineTo(0, size.height); // 结束点,左下角
    path.close();

    return path;
  }

  //是否重新裁剪
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

/// 裁剪当前页的正面
/// [top] 上边的一个点
/// [bottom] 下边的一个点
class SupClip extends CustomClipper<Path> {
  SupClip(this.top, this.bottom);
  Offset top;
  Offset bottom;

  @override
  Path getClip(Size size) {
    // top = Offset(100, 0);
    // bottom = Offset(200, size.height);
    // print("SupClip==getClip=>  top $top, bottom:$bottom");
    assert(
      // 如果top在上边线上
      (top.dy == 0 && top.dx >= 0 && top.dx <= size.width) ||
          // 如果top在右边线上
          (top.dy != 0 && top.dx == size.width),
    );
    assert(
      // 如果 bottom 在下边线上
      (bottom.dy == size.height && bottom.dx >= 0 && bottom.dx <= size.width) ||
          // 如果top在右边线上
          (bottom.dy != size.height && bottom.dx == size.width),
    );

    var path = Path();

    // 需要横向颠倒
    var w = size.width;
    var h = size.height;
    var space = 50.w;
    var isBottom = bottom.dy == h;

    path.moveTo(-space, h + space);
    // 间距
    if (isBottom) path.lineTo(w, bottom.dy + space);
    path.lineTo(w - bottom.dx, bottom.dy); // 添加 bottom
    path.lineTo(w - top.dx, top.dy); // 添加top
    // 间距
    if (isBottom) {
      path.lineTo(w - top.dx - space, 0);
    } else {
      path.lineTo(w, top.dy - space);
    }
    if (top.dy == 0) {
      // 如果top不在最上边的边上,则添加顶点右上角
      path.lineTo(-space, -space);
    }

    // 不加间距版本
    // path.moveTo(0, size.height);
    // path.lineTo(w - bottom.dx, bottom.dy); // 添加top
    // path.lineTo(w - top.dx, top.dy); // 添加top
    // if (top.dy == 0) {
    //   // 如果top不在最上边的边上,则添加顶点右上角
    //   path.lineTo(0, 0.0);
    // }

    path.close();

    return path;
  }

  //是否重新裁剪
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
