import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:provider/provider.dart';
import 'package:novel_app/route.dart';
import 'package:novel_app/util/util.dart';
import 'package:novel_app/provider/provider_setup.dart';


void main() async {
  // 防止热重载报错
  // WidgetsFlutterBinding.ensureInitialized();
  // Provider.debugCheckInvalidValueType = null;
  // runApp(init());
  runApp(await init());
}

Future<Widget> init() async {
  await NovelUtil.initNovelUtil();

  // Timer.periodic(Duration(seconds: 1), (t) {
  //   t.cancel();
  //   print(""" NovelUtil.data.setString("books",""); """);
  //   NovelUtil.data.setString("books","[]");
  // });
  // NovelUtil.data.setString("books","");
  // 初始化状态管理插件
  return MultiProvider(
      providers: providers,
      // 初始化自适应屏幕大小插件
      child: MyApp()
      // ScreenUtil.init(
      //   designSize: Size(360, 690),
      //   allowFontScaling: false,
      //   builder: () => MyApp(),
      // )
      // Consumer<ReaderSettingModel>(
      //   builder: (BuildContext context, ReaderSettingModel appInfo, Widget child) {
      //     print("MultiProvider == build");
      //     return MyApp();
      //   },
      // ),
      );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 状态对象?
    //只能纵向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, //只能纵向
      DeviceOrientation.portraitDown, //只能纵向
    ]);
    return MaterialApp(
      title: '阅读',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      onGenerateRoute: NovelAppRouter().onGenerateRoute,
      // 默认路由  home
      // 阅读页 /reader
      // 首页 /
      initialRoute: "/reader",
      builder: BotToastInit(),
      //1.调用BotToastInit
      navigatorObservers: [BotToastNavigatorObserver()], //2.注册路由观察者
      // home: XxxxPage(),
    );
  }
}
