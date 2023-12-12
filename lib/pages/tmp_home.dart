import 'dart:async';
import 'package:flutter/material.dart';
import 'package:novel_app/components/pageWidget.dart';
import 'package:novel_app/provider/reader_setting_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import './../util/ytx_ScreenUtil.dart';

/// 这是一个临时的首页,主要是测试用
/// 项目完成后这个页面不应该存在
class TempHomePage extends PageWidget {
  Map<String, Object>? args;
  TempHomePage({this.args, Key? key}) : super(key: key);

  @override
  _TempHomePageState createState() => _TempHomePageState();
}

class _TempHomePageState extends State<TempHomePage> {
  Timer? timer;
  double fontSize = 0;
  ReaderSettingModel? provider;
  @override
  void initState() {
    super.initState();
    // print("设置timer");
    // timer?.cancel();
    // timer = Timer.periodic(Duration(seconds: 1), (t) {
    //   print("timer 执行");

    // });
  }

  @override
  Widget build(BuildContext context) {
    // ScreenUtil.init(
    //   BoxConstraints(
    //     maxHeight: MediaQuery.of(context).size.height,
    //     maxWidth: MediaQuery.of(context).size.width,
    //   ),
    //   designSize: Size(750, 1334),
    //   // allowFontScaling: false,
    // );
    ScreenUtil.init(
      context,
      designSize: Size(750, 1334),
      // allowFontScaling: false,
    );
    // print("_TempHomePageState==build");
    // 获取widget树上最近的模型(这个类型的模型)
    provider ??= Provider.of<ReaderSettingModel>(context);
    fontSize = provider!.fontSize;

    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
        child: Container(
          margin: EdgeInsets.symmetric(
            // horizontal: 5.vw,
            vertical: 10.vh,
          ),
          width: 100.vw,
          // height: 80.vh - ScreenUtil().statusBarHeight,
          color: Color(0xFF9CE68A),
          child: Column(
            children: <Widget>[
              const Text('args'),
              Text(
                "${widget.args}",
                style: TextStyle(fontSize: 50.w),
              ),
              Container(
                color: Color(0xFF39BE34),
                width: 170.w,
                height: 200.h,
              ),
              Container(
                color: Color(0xFF3464BE),
                width: 170.w,
                height: ScreenUtil().bottomBarHeight,
              ),
              ElevatedButton(
                child: Text("跳转到阅读页"),
                onPressed: () {
                  Navigator.pushNamed(context, "/reader",
                      arguments: {"a": 1, "b": 2});
                },
              ),
              ElevatedButton(
                child: Text("选择文件"),
                onPressed: () {
                  Navigator.pushNamed(context, "/file/selectBook");
                },
              ),
              ElevatedButton(
                child: Text("书架"),
                onPressed: () {
                  Navigator.pushNamed(context, "/bookrack");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
