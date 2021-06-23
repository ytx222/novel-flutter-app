import 'package:flutter/widgets.dart';

typedef ReaderGestureCallback = void Function(ReaderGestureData data);

/// 手势移动方向
enum GestureMoveDirection {
  top,
  rigth,
  bottom,
  left,
  // none,
}

/// 直接打有点长,所所以定义了4个变量内部使用
var _top = GestureMoveDirection.top;
var _rigth = GestureMoveDirection.rigth;
var _bottom = GestureMoveDirection.bottom;
var _left = GestureMoveDirection.left;
// var null = GestureMoveDirection.none;

/// 每一次手势操作(从手指按下到离开)的所有数据
///
class ReaderGestureData {
  ReaderGestureData({
    required this.start,
  });

  /// 是否移动过
  bool isMove = false;

  bool isTop = false;
  bool isRight = false;
  bool isBottom = false;
  bool isLeft = false;



  /// 开始移动的位置
  Offset start = Offset.zero;

  /// 第一次移动的距离
  Offset firstMove = Offset.zero;

  /// 最后一次移动时的位置
  Offset last = Offset.zero;

  /// 最后一次移动的距离
  Offset lastMove = Offset.zero;

  /// 结束移动的位置
  Offset end = Offset.zero;

  /// 开始移动时的方向,主要方向和次要方向
  // List<GestureMoveDirection> get startDirections => _getDirections(firstMove);

  /// 开始移动时的方向(水平)
  GestureMoveDirection? startDirectionsH;

  /// 开始移动时的方向(纵向)
  GestureMoveDirection? startDirectionsV;

  /// 结束移动时的方向,主要方向和次要方向
  // List<GestureMoveDirection> get endDirections => _getDirections(lastMove);

  /// 结束移动时的方向(水平)
  GestureMoveDirection? endDirectionsH;

  /// 结束移动时的方向(纵向)
  GestureMoveDirection? endDirectionsV;

  /// 根据一个距离,获取水平方向
  GestureMoveDirection _getlDirectionH(Offset delta) {
    return delta.dx > 0 ? _rigth : _left;
  }

  /// 根据一个距离,获取垂直方向
  GestureMoveDirection _getDirectionV(Offset delta) {
    return delta.dy > 0 ? _bottom : _top;
  }

  /// 根据一个移动距离
  List<GestureMoveDirection> _getDirections(Offset delta) {
    var horizontal = _getlDirectionH(delta);
    var vertical = _getDirectionV(delta);
    return delta.dx.abs() >= delta.dy.abs()
        ? <GestureMoveDirection>[horizontal, vertical]
        : <GestureMoveDirection>[vertical, horizontal];
  }
}

/// 手势识别
class ReaderGestureDiscern extends StatefulWidget {
  final Widget? child;

  ReaderGestureDiscern({
    Key? key,
    required this.child,
    required this.onTap,
    required this.onMove,
    required this.onMoveEnd,
  }) : super(key: key);

  /// 按下,没有移动的松开
  final ReaderGestureCallback? onTap;

  /// 按下后移动
  final ReaderGestureCallback? onMove;

  /// 按下后移动然后松开
  final ReaderGestureCallback? onMoveEnd;

  @override
  _ReaderGestureDiscernState createState() => _ReaderGestureDiscernState();
}

class _ReaderGestureDiscernState extends State<ReaderGestureDiscern> {
  /// 承载每一次手势操作的数据
  ReaderGestureData data = ReaderGestureData(start: Offset.zero);
  @override
  Widget build(BuildContext context) {
    //FIXME:这里不能监听原始指针,因为不能正常被覆盖
    return GestureDetector(
      /// 指针已接触屏幕并可能开始移动。
      /// 这个事件中处理对移动逻辑
      onPanDown: (e) {
        print("=========================================onPanDown");
        print(e);
        data = ReaderGestureData(start: e.globalPosition);
      },

      /// 与屏幕接触并移动的指针再次移动。
      onPanUpdate: (e) {
        // print("继续移动 ");
        // print("move");
        var delta = e.delta;
        if (e.delta == Offset.zero) {
          return;
        }
        // 保存最后移动
        data.lastMove = delta;
        data.last = e.globalPosition;
        // 保存首次移动
        if (data.firstMove == Offset.zero) data.firstMove = delta;
        // 移动过了
        data.isMove = true;
        // 根据不同方向,设置是否向这个方向移动过
        if (delta.dx > 0.0) data.isRight = true;
        if (delta.dx < 0.0) data.isLeft = true;
        if (delta.dy > 0.0) data.isBottom = true;
        if (delta.dy < 0.0) data.isTop = true;
        // 更新方向信息
        // start以第一次不为0的数据为准,
        // end以最后一次不为0的数据为准
        if (delta.dx != 0.0) {
          var d = delta.dx > 0 ? _rigth : _left;
          data.startDirectionsH ??= d;
          data.endDirectionsH = d;
        }
        if (delta.dy != 0.0) {
          var d = delta.dy > 0 ? _bottom : _top;
          data.startDirectionsV ??= d;
          data.endDirectionsV = d;
        }

        // 判断是否转向过,先不做了,好像不需要
        // if(data.)
        // print(e.delta);
        widget.onMove?.call(data);
      },
      onPanEnd: (e) async {
        print("移动完成");
        data.end = data.last;
        // data.lastMove = e.delta;
        if (data.isMove) {
          widget.onMoveEnd?.call(data);
        } else {
          print("tap======================");
          widget.onTap?.call(data);
        }
      },
      child: widget.child,
    );
  }
}
