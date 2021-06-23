import 'package:flutter/material.dart';
import 'package:novel_app/pages/bookrack/bookrack.dart';
import 'package:novel_app/pages/reader/reader_page.dart';
import 'package:novel_app/pages/tmp_home.dart';

import 'components/pageWidget.dart';
import 'pages/file/selectBook.dart';

/// 一个返回页面的函数,避免直接初始化页面实例
typedef PageWidget GetWidget(Map<String, Object>? args);

/// 配置app的所有页面
var pageList = [
  PageItem((e) => ReaderPage(args: e), "/reader", "ReaderPage"),
  PageItem((e) => TempHomePage(args: e), "/", "主页"),
  PageItem((e) => SelectBookPage(args: e), "/file/selectBook", "selectBook"),
  PageItem((e) => BookrackPage(args: e), "/bookrack", "bookrack"),
];

/// 页面对象
class PageItem {
  GetWidget getWidget;
  String name;
  String routeName;
  PageItem(this.getWidget, this.routeName, this.name);
}

/// 路由类
/// 提供一个 onGenerateRoute 方法
class NovelAppRouter {
  late Map<String, PageItem> pageMap;
  NovelAppRouter() {
    pageMap = {};
    pageList.forEach((page) {
      var map = <String, PageItem>{page.routeName: page};
      pageMap.addAll(map);
    });
  }

  /// 负责路由的方法
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    //  Navigator.of(context).pop();

    String? routeName = settings.name;
    PageItem? item = pageMap[routeName!];
    print("===============onGenerateRoute $item ");
    if (item == null) {
      // 如果页面不存在,返回404页面(没有404页面,返回首页)
      return MaterialPageRoute(builder: (context) {
        return TempHomePage(args: {'msg': '404'});
      });
    }
    // 如果访问的路由页需要登录，但当前未登录，则直接返回登录页路由，
    // if(){
    //  ...
    //}
    // 引导用户登录；其它情况则正常打开路由。

    return MaterialPageRoute(builder: (context) {
      // 遍历一遍参数,因为可能有 可空类型传进来,
      //这样的情况,对于null,忽略参数,对于非null,则正常传递
      Map<String, Object?>? _parms = settings.arguments == null
          ? null
          : settings.arguments as Map<String, Object?>?;
      var parms = <String, Object>{};
      _parms?.forEach((key, value) {
        if (key.isNotEmpty && value != null) {
          parms[key] = value;
        }
      });
      return item.getWidget(parms);
      // 如果访问的路由页需要登录，但当前未登录，则直接返回登录页路由，
      // 引导用户登录；其它情况则正常打开路由。
    });
  }
}
