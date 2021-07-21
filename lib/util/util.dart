import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmkv/mmkv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef GetCacheFn(Function fn);

class NovelUtil {
  static Future initNovelUtil() async {
    await MMKV.initialize(logLevel: MMKVLogLevel.None);
  }

  static _Date date = const _Date();
  static _Data data = _Data();

  /// 等待一定时间
  Future<void> sleep(int ms) {
    var completer = new Completer<void>();
    Timer.periodic(Duration(milliseconds: ms), (timer) {
      timer.cancel();
      completer.complete();
    });
    return completer.future;
  }

  ///计算文件大小,代码来着包 filesize 由于没有适配空安全,所以复制出来
  static String filesize(dynamic size, [int round = 2]) {
    /**
   * [size] can be passed as number or as string
   *
   * the optional parameter [round] specifies the number
   * of digits after comma/point (default is 2)
   */
    int divider = 1024;
    int _size;
    try {
      _size = int.parse(size.toString());
    } catch (e) {
      throw ArgumentError("Can not parse the size parameter: $e");
    }

    if (_size < divider) {
      return "$_size B";
    }

    if (_size < divider * divider && _size % divider == 0) {
      return "${(_size / divider).toStringAsFixed(0)} KB";
    }

    if (_size < divider * divider) {
      return "${(_size / divider).toStringAsFixed(round)} KB";
    }

    if (_size < divider * divider * divider && _size % divider == 0) {
      return "${(_size / (divider * divider)).toStringAsFixed(0)} MB";
    }

    if (_size < divider * divider * divider) {
      return "${(_size / divider / divider).toStringAsFixed(round)} MB";
    }

    if (_size < divider * divider * divider * divider && _size % divider == 0) {
      return "${(_size / (divider * divider * divider)).toStringAsFixed(0)} GB";
    }

    if (_size < divider * divider * divider * divider) {
      return "${(_size / divider / divider / divider).toStringAsFixed(round)} GB";
    }

    if (_size < divider * divider * divider * divider * divider &&
        _size % divider == 0) {
      num r = _size / divider / divider / divider / divider;
      return "${r.toStringAsFixed(0)} TB";
    }

    if (_size < divider * divider * divider * divider * divider) {
      num r = _size / divider / divider / divider / divider;
      return "${r.toStringAsFixed(round)} TB";
    }

    if (_size < divider * divider * divider * divider * divider * divider &&
        _size % divider == 0) {
      num r = _size / divider / divider / divider / divider / divider;
      return "${r.toStringAsFixed(0)} PB";
    } else {
      num r = _size / divider / divider / divider / divider / divider;
      return "${r.toStringAsFixed(round)} PB";
    }
  }

  /// 显示显示一条文字提示
  /// 可以自定义样式,但现在先不改
  static void msg(
    String text, {
    TextStyle? style,
  }) {
    BotToast.showText(text: text);
  }

  static Future<bool> alertText(
    String text, {
    TextStyle? style,
    String title = "提醒",
     double height = 0,
    bool showCancel = true,
  }) {
    return alert(
      title: title,
      content: SingleChildScrollView(
              child: Container(
          padding: EdgeInsets.all(10.w),
          child: Text(
            text,
            style: style ?? TextStyle(fontSize: 32.w, color: Color(0xFF444444)),
          ),
        ),
      ),
      height:height,
      showCancel: showCancel,
    );
  }

  /// 通用的title和按钮区域的高度

  /// 弹窗
  static Future<bool> alert({
    required Widget? content,
    String title = "提醒",
    String cancelText = "取消",
    double height = 0,
    bool showCancel = true,
    GetCacheFn? getCancelFunc,
    Function? resolve,
    Function? reject,
  }) {
    Completer<bool> completer = new Completer();
    // 一些变量
    // ignore: non_constant_identifier_names
    var HEIGHT = 88.w;
    // ignore: non_constant_identifier_names
    var BORDERWIDTH = 1.w;
    BotToast.showEnhancedWidget(
      crossPage: false,
      allowClick: false,
      toastBuilder: (cancelFunc) {
        // 如果高度不到400 就设置最低400
        if (height < 400.w) {
          height = 400.w;
        }
        if (getCancelFunc != null) {
          getCancelFunc(cancelFunc);
        }

        return Container(
          decoration: BoxDecoration(color: Color(0x22000000)),
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(20.w),
            ),
            width: 600.w,
            height: height,
            // 整体的容器
            child: Column(
              children: [
                // 标题栏
                Container(
                  height: HEIGHT,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 50.w),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 36.w, color: Color(0xFF444444)),
                  ),
                ),
                // 内容栏
                Expanded(
                  child: Container(
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                            color: Color(0xFFE4E4E4), width: BORDERWIDTH),
                      ),
                    ),
                    // 填充的内容
                    child: content,
                  ),
                ),
                // 底部按钮
                Container(
                  // color: Color(0xFFA13C3C),
                  height: HEIGHT,
                  child: OverflowBox(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!showCancel)
                          _alertFooterBtn(
                            completer: completer,
                            res: false,
                            text: "取消",
                            fn: reject,
                            cancelFunc: cancelFunc,
                            ts: TextStyle(color: Color(0xFF999999)),
                          ),

                        // 垂直分割线
                        // VerticalDivider(
                        //   color: Color(0xFFE4E4E4),
                        //   width: 1,
                        // ),
                        SizedBox(
                          width: BORDERWIDTH,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xFFE4E4E4),
                            ),
                          ),
                        ),
                        _alertFooterBtn(
                          completer: completer,
                          fn: resolve,
                          cancelFunc: cancelFunc,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );

    return completer.future;
  }
}

Widget _alertFooterBtn({
  required Completer completer,
  bool res = true,
  String text = '确定',
  fn,
  cancelFunc,
  TextStyle? ts,
}) {
  return Expanded(
    child: TextButton(
      child: Text(
        text,
        style: ts,
      ),
      onPressed: () {
        completer.complete(res);
        // 如果返回值不是false,则执行cancelFunc
        bool? _is = true;
        if (fn != null) {
          _is = fn();
        }
        if (_is != false) {
          cancelFunc();
        }
      },
    ),
  );
}

class _Date {
  const _Date();
  String fullDate(DateTime date) {
    return formatDate(
      date,
      [yyyy, "-", mm, "-", dd, " ", hh, ":", nn, ":", ss],
    );
  }

  /// 返回日期部分
  String toDate(date, {bool sec = true}) {
    return formatDate(
      date,
      [yyyy, "-", mm, "-", dd],
    );
  }

  /// 返回时间部分
  String toTime({DateTime? date, bool sec = true}) {
    date ??= DateTime.now();
    return formatDate(
      date,
      sec ? [HH, ":", nn, ":", ss] : [HH, ":", nn],
    );
  }
}

/// 数据存储
class _Data {
  var rootDir;
  late MMKV mmkv;
  // SharedPreferences prefs;
  _Data() {
    mmkv = MMKV("test-encryption");
  }

  /// 设置一个字符串
  bool setString(String key, String value) {
    return mmkv.encodeString(key, value);
  }

  /// 获取一个字符串
  String? getString(String key) {
    return mmkv.decodeString(key);
  }

  /// 获取map
  Map getJsonMap(String key) {
    var s = mmkv.decodeString(key) ?? "{}";
    return json.decode(s) as Map;
  }

  /// 获取list
  List getJsonList(String key) {
    var s = mmkv.decodeString(key) ?? "[]";
    return json.decode(s) as List;
  }

  /// 删除某个值,其实就是设置为空字符串
  void delete(String key) {
    mmkv.removeValue(key);
  }

  // Object getData(String key) {
  //   return jsonDecode(prefs.getString(key));
  // }

  // void setData(String key, Object data) {
  //   prefs.setString(key, jsonEncode(data));
  // }
}
