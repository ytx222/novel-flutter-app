import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_app/pages/reader/widget/reader_page_container.dart';
import 'package:novel_app/provider/reader_data_model.dart';
import 'package:novel_app/provider/reader_setting_model.dart';
import 'package:novel_app/util/split_util.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:novel_app/class/book.dart';
import 'package:novel_app/components/pageWidget.dart';
import 'package:novel_app/util/ytx_ScreenUtil.dart';

class ReaderPage extends PageWidget {
  final Map<String, Object>? args;
  ReaderPage({this.args, Key? key}) : super(key: key);

  @override
  _ReaderPageState createState() => _ReaderPageState(args);
}

class _ReaderPageState extends State<ReaderPage> {
  /// 初始化类
  _ReaderPageState(Map<String, Object>? args) {
    print("初始化reader页面 args: $args");
    if (args != null) {
      book = args["book"] as Book?;
    }
  }

  /// 书对象
  Book? book;

  /// 当前书对象,逻辑大多数都在这里,书对象就是用来初始化这个对象的
  ReaderDataModel? readerData;

  /// 阅读设置
  ReaderSettingModel? setting;

  Widget? readerContainer;

  /// 初始化时
  initState() {
    super.initState();
    Wakelock.enable();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  /// 页面关闭时
  dispose() {
    super.dispose();

    Wakelock.disable();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //     //设置状态栏透明,用这个需要设置计时器
    //     statusBarColor:Color(0x44000000) ,
    //     statusBarBrightness: Brightness.dark,
    //   ));
  }

  @override
  Widget build(BuildContext context) {
    readerContainer ??= ReaderPageContainer();
    if (setting == null) {
      setting = Provider.of<ReaderSettingModel>(context);
      SplitUtil.init(setting!);
    }

    /// 初始化当前书对象
    if (readerData == null) {
      // print('readerData == null');
      readerData = Provider.of<ReaderDataModel>(context);
      readerData!.init(book);
    }
    print("100%=${100.vw}");
    return Scaffold(
      body: Container(
        width: 100.vw,
        height: 1334.h,

        ///FIXME: 间距,需要读取阅读设置
        child: Stack(
          children: [
            readerContainer!,
          ],
        ),
      ),
    );
  }
}
