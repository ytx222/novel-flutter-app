import 'package:flutter/material.dart';
import 'package:novel_app/pages/reader/animation/bese_animation_page.dart';
import 'package:novel_app/pages/reader/animation/cover_animation_page.dart';
import 'package:novel_app/pages/reader/animation/simulation_animation_page.dart';
import 'package:novel_app/pages/reader/widget/reader_gesture_discern.dart';
import 'package:novel_app/pages/reader/widget/reader_item_system_info.dart';
import 'package:novel_app/pages/reader/menu/reader_menu.dart';
import 'package:novel_app/provider/reader_data_model.dart';
import 'package:novel_app/provider/reader_setting_model.dart';
import 'package:novel_app/util/native_api.dart';
import 'package:novel_app/util/util.dart';
import 'package:novel_app/util/utils_screen.dart';
import 'package:provider/provider.dart';

/// 盛放多个页面,
/// 翻页相关逻辑处理
/// 弹出菜单逻辑处理
class ReaderPageContainer extends StatefulWidget {
  ReaderPageContainer({GlobalKey<_ReaderPageContainerState>? key})
      : super(key: key ?? GlobalKey<_ReaderPageContainerState>()) {
    globalKey = this.key as GlobalKey<_ReaderPageContainerState>;
  }

  static GlobalKey<_ReaderPageContainerState>? globalKey;

  @override
  _ReaderPageContainerState createState() {
    return _ReaderPageContainerState();
  }
}

class _ReaderPageContainerState extends State<ReaderPageContainer> {
  // TODO: 每次build都重新生成GlobalKey试试
  // static var menuKey = new GlobalKey<_ReaderMenuState>();
  /// 动画管理页面的的key
  var menuKey = new GlobalKey<ReaderMenuState>();
  ReaderMenu? menu;

  /// 动画管理页面的的key
  var animationKey = new GlobalKey<BaseAnimationPageState>();

  /// 当前书对象,逻辑大多数都在这里,书对象就是用来初始化这个对象的
  ReaderDataModel? readerData;

  /// 阅读设置,这里获取是因为要判断翻页动画类型,返回不同页面(BaseAnimationPage)
  late ReaderSettingModel setting;
  @override
  void initState() {
    print(
        "阅读-container initState================================================= ");
    super.initState();

    menu = ReaderMenu(key: menuKey);

    // 初始化电量
    // NativeApi.getBatteryLevel();
    // 设置开始监听电量
    NativeApi.setBatteryChangeObserver(true);
    // 设置开始拦截音量键
    NativeApi.setVolumeIntercept(true);
    // 对于原生端事件的监听
    NativeApi.platform.setMethodCallHandler((call) async {
      // 这个注册回调,如果在其他页面操作被拦截之后,再进入阅读页面,就会产生这样的效果,所以在pageChage做了拦截
      print("收到java传来的消息=$call");
      if (call.method == 'volumeChange') {
        int v = call.arguments;
        if (v == 0) {
          nextPage();
        } else {
          prevPage();
        }
      } else if (call.method == 'batteryChange') {
        List v = call.arguments;
        print("电量变化== $v - ${NovelUtil.date.fullDate(DateTime.now())}");
        setState(() {
          // battery = v[0];
          ReaderItemSystemInfo.setBattery(v[0]);
        });
      } else if (call.method == 'timer') {
        print("收到timer==${call.arguments}");
      }
    });
  }

  @override
  void dispose() {
    // 设置不再拦截音量键
    NativeApi.setVolumeIntercept(false);
    NativeApi.platform.setMethodCallHandler(null);
    super.dispose();
  }
  // Widget item;

  @override
  Widget build(BuildContext context) {
    // var route = ModalRoute.of(context);
    // route.addScopedWillPopCallback(() => null);

    readerData = Provider.of<ReaderDataModel>(context);
    setting = Provider.of<ReaderSettingModel>(context);
    return Positioned.fill(
      child: WillPopScope(
        onWillPop: () async {
          print("用户尝试返回,但是被拦截了");
          return false;
          // return true;
        },

        /// 先临时增加,之后会删除GestureDetector
        child: ReaderGestureDiscern(
          onTap: (e) {
            var _is = animationKey.currentState?.onTap(e);
            if (_is == false) {
              ReaderMenu.show();
            }
          },
          onMove: (e) {
            animationKey.currentState?.onMove(e);
          },
          onMoveEnd: (e) {
            animationKey.currentState?.onMoveEnd(e);
          },
          child: Container(
            // color: Color(0xFF000000),
            child: Stack(
              children: [
                getReaderPageItems(context),

                /// 菜单
                menu!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 下一页
  Future<void> nextPage() async {
    // await pageChange(1);
    animationKey.currentState?.nextPage();
  }

  /// 上一页
  Future<void> prevPage() async {
    // await pageChange(-1);
    animationKey.currentState?.prevPage();
  }

  Future<void> pageChange(num n) async {
    if (readerData == null || !readerData!.initEnd) {
      return;
    }
    // 一直写!太麻烦
    var _readerData = readerData!;
    // _readerData.setPage(n);
    var newValue = _readerData.page + n;
    var len = _readerData.pageNum;

    if (newValue >= 0 && newValue <= len) {
      _readerData.setPage(newValue);
    } else {
      print("触发章节更新$n");
      var newChapter = _readerData.chapterIndex + n;
      var chapterLength = _readerData.chapterLength;
      // chapterChange(n);
      print(newValue >= len && newChapter < chapterLength);
      print("$newValue , $len, $newChapter , $chapterLength");
      bool _is = false;
      if (newValue >= len) {
        // 下一章
        _is = _readerData.nextChapter();
      } else {
        // 上一章
        // chapterChange(1);
        _is = _readerData.prevChapter();
      }

      if (!_is) NovelUtil.msg("无法翻页");
    }
  }

  Future<void> chapterChange(num n) async {
    // readerData.setPage(n);
    var newValue = readerData!.chapterIndex + n;
    var len = readerData!.chapterLength;
    if (newValue >= 0 && newValue < len) {
      readerData!.setChapter(newValue as int);
    } else {
      NovelUtil.msg("无法翻页");
    }
  }

  // Future<void> nextChapter() async {
  //   await pageChange(-1);
  // }

  // Future<void> prevChapter() async {
  //   await pageChange(-1);
  // }

  Widget getReaderPageItems(BuildContext context) {
    // 没有加载完成时返回加载中
    if (!readerData!.initEnd) {
      return _loading();
    } else if (readerData!.book == null) {
      return _loadError(context);
    } else {
      BaseAnimationPage animationPage;
      if (setting.turnAnimationType == TurnAnimationType.cover) {
        animationPage = CoverAnimationPage(key: animationKey);
      } else if (setting.turnAnimationType == TurnAnimationType.simulation) {
        animationPage = SimulationAnimationPage(key: animationKey);
      }
      //  else if (setting.turnAnimationType == 'none') {
      //   animationPage = SimulationAnimationPage(key: animationKey);
      // }
      else {
        /// 默认值
        /// CoverAnimationPage
        /// SimulationAnimationPage
        animationPage = CoverAnimationPage(key: animationKey);
      }
      return animationPage;
    }
  }
}

Widget _loading() {
  return Center(
    child: Text("加载中..."),
  );
}

Widget _loadError(BuildContext context) {
  return Container(
    alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "加载书籍失败了!",
          style: TextStyle(fontSize: 30),
        ),
        ElevatedButton(
          child: Text("去书架找本书看吧!"),
          onLongPress: () async {
            await NovelUtil.alertText("怎么,不想去么?");
          },
          onPressed: () {
            ///FIXME: 检查页面历史是否有书架页面,如果有,返回多级页面,如果没有,跳转过去
            Navigator.pushNamed(context, "/bookrack");
            // Navigator.pushNamed(context, '/routeName');
            // var a = new ReaderPageContainer();
            // Navigator.pop(context);
          },
        )
      ],
    ),
  );
}
