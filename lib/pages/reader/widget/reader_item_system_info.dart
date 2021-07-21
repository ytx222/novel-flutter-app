import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:novel_app/util/util.dart';

var _list = <_ReaderItemSystemInfoState>[];
Timer? t;

class ReaderItemSystemInfo extends StatefulWidget {
  final TextStyle style;
  ReaderItemSystemInfo({
    Key? key,
    required this.style,
  }) : super(key: key) {
    /// FIXME: 增加秒设置项
    ReaderItemSystemInfo.date = NovelUtil.date.toTime(sec: false);
    t?.cancel();
    t = Timer.periodic(Duration(seconds: 1), (t) {
      var newDate = NovelUtil.date.toTime(sec: false);
      if (newDate != ReaderItemSystemInfo.date) {
        ReaderItemSystemInfo.date = newDate;
        // 循环赋值
        _list.forEach((element) {
          element.change();
        });
      }
    });
  }

  static var date = '';
  static int battery = 0;
  static void setBattery(int v) {
    if (v != battery) {
      battery = v;
      _list.forEach((element) {
        element.change();
      });
    }
  }

  @override
  _ReaderItemSystemInfoState createState() {
    return _ReaderItemSystemInfoState();
  }
}

class _ReaderItemSystemInfoState extends State<ReaderItemSystemInfo> {
  @override
  void initState() {
    super.initState();
    _list.add(this);
  }

  @override
  void dispose() {
    super.dispose();
    _list.remove(this);
  }

  void change() {
    // 调一下setState以重新build
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // print("系统信息栏--build");
    // var barFontstyle = TextStyle(
    //   fontSize: 24.w,
    //   color: Color(0xFF444444),
    // );
    return Text(
      "${ReaderItemSystemInfo.date} | ${ReaderItemSystemInfo.battery}%",
      style: widget.style,
    );
  }
}
