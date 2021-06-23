import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:novel_app/util/ytx_ScreenUtil.dart';

class YtxScrollBar extends StatefulWidget {
  final bool isRow;

  final Widget child;

  // final ScrollController? controller;
  final ScrollController controller;

  // final double initOffset;

  /// 初始化
  /// [child] 可滚动的子元素
  /// [controller] 因为不能自己加滚动控制器,没有统一的类型,所以目前滚动控制器是必填参数
  YtxScrollBar({
    Key? key,
    required this.child,
    required this.controller,
    this.isRow = false,
    // this.initOffset = 0,
  }) : super(key: key);

  @override
  _YtxScrollBarState createState() {
    // ScrollController _controller;
    // if (controller != null) {
    //   _controller = controller!;
    // } else {
    //   _controller = ScrollController();
    // }
    // return _YtxScrollBarState(controller: _controller);
    return _YtxScrollBarState(controller: controller);
  }
}

class _YtxScrollBarState extends State<YtxScrollBar> {
  /// 滚动控制器
  final ScrollController controller;

  /// 是否初始化
  // bool isInit = false;

  /// 总滚动长度
  double max = 10;

  /// 当前滚动长度
  double cur = 1;

  /// 容器的长度(滚动方向的)
  double size = 10;

  /// 是否显示滚动条
  bool showBar = true;

  /// 滚动条的长度
  double barSize = 0;

  double get barScrollDist => size - barSize;

  /// 列表距离屏幕顶部的距离
  double barTopOffset = 0;

  /// 拖动开始位置
  double startDy = 0;

  double startTop = 0;

  /// 当前拖动到的位置
  double curDy = 0;

  /// 用于自动隐藏bar的定时器
  Timer? t;

  _YtxScrollBarState({required this.controller});

  @override
  void initState() {
    hideBar();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    t?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // print("bar==build++++++++++++++++++++++++++++++++++++++++++++++++++++++");

    return Container(
      constraints: BoxConstraints(maxWidth: 100),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification e) {
          var data = e.metrics;
          // print(data);
          // print("${data.pixels} / ${data.maxScrollExtent}");
          // print("${cur} ${data.viewportDimension}");

          setState(() {
            cur = data.pixels;
            max = data.maxScrollExtent;
            size = data.viewportDimension;
            if (barSize == 0) {
              calcBarSize();
            }
            showBar = true;
          });
          hideBar();
          return false;
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: widget.child,
            ),
            bar()
          ],
        ),
      ),
    );
  }

  /// 计算滚动条高度
  double calcBarSize() {
    var v = size / (max + size) * size;
    if (v < 100.w) {
      v = 100.w;
    }
    if (v.isNaN) {
      v = double.infinity;
    }
    // 因为这个计算会在build执行完成之前赋值,所以不需要setstate
    print("calcBarSize==$size/$max $v");
    return barSize = v;
  }

  /// 设置三秒后隐藏滚动条
  void hideBar() {
    t?.cancel();
    t = Timer.periodic(Duration(seconds: 3), (t) {
      t.cancel();
      setState(() {
        showBar = false;
      });
    });
  }

  Widget bar() {
    if (max == 0) {
      return Container();
    }
    var v = (cur / max);

    var top = barScrollDist * v;

    // print("bar参数计算完成 cur:$cur max:$max v=$v");
    return Positioned(
      right: 0,
      top: top,
      child: GestureDetector(
        /**
         * 这里有两种方案,
         * 1.对滚动条绑定事件,然后计算逻辑稍微复杂一点,即当前方案
         * 2.对Stack和其他子元素绑定,这样Stack就只会收到滚动条的,
         *   这样会造成多余影响,并且布局更复杂所以不使用
         */
        onTapUp: (details) {},

        /// 指针已接触屏幕并可能开始移动。
        /// 这个事件中处理对移动逻辑
        onPanDown: (details) {
          hideBar();
          // print("滚动条--按下,可能移动");
          // start = details.globalPosition;
          barTopOffset =
              details.globalPosition.dy - top - details.localPosition.dy;
          print(barTopOffset);

          startDy = details.globalPosition.dy;
          startTop = top;
        },

        /// 指针已经接触屏幕并开始移动。
        onPanStart: (details) {
          hideBar();
          // print("滚动条--按下,移动中");
          // move(details.globalPosition);
          move(details.globalPosition.dy - barTopOffset);
        },

        /// 与屏幕接触并移动的指针再次移动。
        onPanUpdate: (details) {
          hideBar();
          // print("滚动条--继续移动 ");
          move(details.globalPosition.dy - barTopOffset);
        },
        onPanEnd: (details) async {
          hideBar();
          // print("滚动条--移动完成");
          // await moveEnd();
        },
        child: AnimatedOpacity(
          opacity: showBar ? 1 : 0,
          duration: Duration(milliseconds: showBar ? 0 : 300),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0x44000000),
            ),
            width: 40.w,
            height: barSize,
            child: null,
          ),
        ),
      ),
    );
  }

  void move(double newDy) {
    // print("move");
    // 移动一定距离触发一次
    if ((newDy - curDy).abs() > 1 || newDy <= 0 || newDy > size - 1) {
      curDy = newDy;
      if (newDy < 0) {
        newDy = 0;
      } else if (newDy > size) {
        newDy = size;
      }
      var newScroll = newDy / size * max;
      // print("move==  $newDy 总$newScroll");
      controller.jumpTo(newScroll);
    } else {
      // print("move==被抛弃");
    }
  }
}
