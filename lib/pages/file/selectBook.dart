import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:novel_app/class/book.dart';
import 'package:novel_app/components/pageWidget.dart';
import 'package:novel_app/provider/books_model.dart';
import 'package:novel_app/provider/select_book_filter_model.dart';
import 'package:novel_app/util/file_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:novel_app/util/util.dart';
import 'package:provider/provider.dart';
// import 'package:path_provider/path_provider.dart';

class SelectBookPage extends PageWidget {
  SelectBookPage({
    Map<String, Object>? args,
    Key? key,
  }) : super(key: key, args: args);

  @override
  _SelectBookPageState createState() => _SelectBookPageState(args);
}

class _SelectBookPageState extends State<SelectBookPage> {
  /// 0 = 文字  1 = 显示列表
  int showType = 0;

  /// 显示文字模式下显示的文字
  String showText = "正在获取权限...\n请选择允许读取本机文件";

  /// 显示文字模式文字样式
  TextStyle showTextStyle = TextStyle(fontSize: 24, color: Color(0xFF333333));

  /// 显示文字模式下的额外按钮是否需要显示
  bool isShowButton = false;

  _SelectBookPageState(Map<String, Object>? args) {
    print(args);
    print("==============================");
    init();
  }

  Future init() async {
    int type = await getPermission();
    print("type======================$type");
    setState(() {
      // 给权限了
      if (type == 1) {
        showType = 1;
      } else if (type == 0) {
        // 没有给权限则..
        BotToast.showText(text: "授权失败");
        showText = "您已禁止本App访问本机文件,如果想要使用本功能请点击按钮并给予权限,如果无效,请在系统设置中赋予本App权限";
        showTextStyle = TextStyle(
          fontSize: 20,
          color: Color(0xFFF77070),
        );
      } else if (type == -1) {
        showText =
            "您已永久禁止本App访问文件的权限,恭喜你触发彩蛋,获得作者的如来神掌\n\n如果需要重新给予权限,卸载重装app和系统设置中修改均可";
        showTextStyle = TextStyle(
          fontSize: 20,
          color: Color(0xFFF77070),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var booksModel = Provider.of<BooksModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("选择文件$showType - ${booksModel.list.length}"),
      ),
      body: Container(
        child: <Widget>[
          // 状态1,显示文字
          Container(
            padding: EdgeInsets.all(20),
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Text(showText, style: showTextStyle),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Color(0xFF6BB6F3),
                    ),
                  ),
                  child: Text(
                    "授权",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    await init();
                  },
                )
              ],
            ),
          ),
          // 状态2,显示列表
          _FileListWidget()
        ][showType],
      ),
    );
  }
}

class _FileListWidget extends StatefulWidget {
  _FileListWidget({Key? key}) : super(key: key);

  @override
  __FileListWidgetState createState() => __FileListWidgetState();
}

class __FileListWidgetState extends State<_FileListWidget> {
  String rootPath = "/storage/emulated/0/";
  List<String> pathList = [];
  List<double> scrollList = [0.0];
  // String path = "";
  String get path => pathList.join("/");
  List<Widget> widgetList = [const ListTile(title: Text("加载中..."))];

  DateTime _lastPressedAt = DateTime.now();
  // 返回上一页的间隔时间
  Duration returnTime = const Duration(seconds: 2);
  // 滚动控制器
  ScrollController controller = new ScrollController();

  /// 所有书的模型
  BooksModel? booksModel;

  /// 筛选条件
  SelectBookFilterModel? filterModel;

  /// 当前路径下的全部文件项目,筛选条件更新时就根据这个
  List<FileItem> fullList = [];

  ///  fullList存的路径.用于路径更新后更新fullList
  String fullListPath = './';

  /// 筛选弹窗
  _FilterBox filterBox = _FilterBox();

  /// 自己定义一个future避免由于重复build造成一直请求文件
  var future;

  @override
  void initState() {
    super.initState();
    // initList();
  }

  @override
  Widget build(BuildContext context) {
    print("__FileListWidgetState==重新build");
    filterModel = Provider.of<SelectBookFilterModel>(context);
    booksModel = Provider.of<BooksModel>(context);

    // 初始化列表
    return FutureBuilder(
      future: initList(),
      builder: (content, _) {
        print("FutureBuilder==build");
        return WillPopScope(
          onWillPop: () async {
            print("onWillPop");
            if (pathList.isNotEmpty) {
              await exitDir();
            } else if (DateTime.now().difference(_lastPressedAt) > returnTime) {
              //两次点击间隔超过2秒则重新计时
              _lastPressedAt = DateTime.now();
              BotToast.showText(text: "再按一次返回上级页面", duration: returnTime);
              return false;
            } else {
              return true;
            }
            return false;
          },
          child: Container(
            child: Column(
              children: [
                Container(
                  // height: 80.w,
                  padding: EdgeInsets.symmetric(vertical: 15.w),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1,
                        color: Color(0xFFE6E6E6),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 0, 0),
                          child: Text("/" + path),
                        ),
                      ),
                      Container(
                        width: 120.w,
                        height: 40.w,
                        child: TextButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(0),
                            ),
                          ),
                          // padding: EdgeInsets.all(0),
                          child: Text(
                            "筛选",
                            style: TextStyle(
                              color: Color(0xFF444444),
                              fontSize: 26.w,
                            ),
                          ),
                          onPressed: () {
                            NovelUtil.alert(
                              content: filterBox,
                              title: "筛选",
                              height: 400,
                            );
                            print("点击筛选");
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    child: ListView(
                      children: widgetList,
                      // 滚动控制器
                      controller: controller,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  /// 保存当前层级的滚动高度
  void saveScroll() {
    print("saveScroll: ${controller.offset}");
    scrollList.add(controller.offset);
  }

  /// 获取当前层级之前保存的滚动高度
  void readScroll() {
    double scroll = scrollList.length == 0 ? 0 : scrollList.removeLast();
    print("readScroll: $scroll");
    // 有时候一次设置不成功，所以加个计时器设置两次，成功几率目前100%
    controller.jumpTo(scroll);
    // Timer.periodic(Duration(milliseconds: 100), (timer) {
    //   timer.cancel();
    //   controller.jumpTo(scroll);
    // });
  }

  /// 进入下一级目录
  Future<void> openDir(String dirName) async {
    //保存滚动高度
    saveScroll();
    // 添加下一个目录后进行初始化
    pathList.add(dirName);
    await initList();
    // 跳转之后高度设置为0
    controller.jumpTo(0);
  }

  /// 从目录返回
  Future<void> exitDir() async {
    pathList.removeLast();
    await initList();
    readScroll();
  }

  /// 初始化list
  Future initList() async {
    print("initList--");
    List<FileItem> list;

    // 初始化list
    if (fullListPath == path) {
      list = <FileItem>[]..addAll(fullList);
    } else {
      list = await getDirChild(rootPath + path);
      print('getDirChild============ "${rootPath + path}"');
      print(list);
      fullListPath = path;
      fullList = <FileItem>[]..addAll(list);
    }
    // 筛选
    filter(list);
    // 构建widget
    var t = <Widget>[];
    for (var i = 0; i < list.length; i++) {
      t.add(_ListItem(list[i], this));
    }
    // 更新
    setState(() => widgetList = t);
    print("widgetList==");
    print(t);
    return null;
  }

  /// 筛选逻辑
  List<FileItem> filter(List<FileItem> list) {
    print("执行筛选");
    print(filterModel);
    // 是否显示普通文件
    bool isNotShowFile = !(filterModel!.isShowFile);
    // 是否显示以.开头的文件
    bool isNotShowDotFile = !(filterModel!.isShowDotFile);
    print("isNotShowFile:$isNotShowFile, isNotShowDotFile:$isNotShowDotFile");
    list.removeWhere((item) {
      if (isNotShowFile && item.type == FileItemType.file) {
        return true;
      }
      if (isNotShowDotFile && item.name.startsWith(".")) {
        return true;
      }
      return false;
    });
    // 排序
    if (filterModel!.sortType != FileItemSortType.none) {
      int t = filterModel!.sortType == FileItemSortType.asc ? 1 : -1;
      list.sort((v1, v2) {
        return v1.name.compareTo(v2.name) * t;
      });
    }
    print("筛选完成后列表");
    print(list);
    return list;
  }
}

class _FilterBox extends StatefulWidget {
  _FilterBox({Key? key}) : super(key: key);

  @override
  __FilterBoxState createState() => __FilterBoxState();
}

class __FilterBoxState extends State<_FilterBox> {
  /// 排序类型
  int? sortValue;

  /// 筛选模型
  late SelectBookFilterModel filterModel;
  @override
  Widget build(BuildContext context) {
    filterModel = Provider.of<SelectBookFilterModel>(context);
    // 初始化sortValue的值
    sortValue = <FileItemSortType, int>{
      FileItemSortType.none: 0,
      FileItemSortType.asc: 1,
      FileItemSortType.desc: 2
    }[filterModel.sortType];
    return Scaffold(
      body: Container(
        // height: 400,
        alignment: Alignment.center,
        child: Column(
          children: [
            CheckboxListTile(
              title: Text("显示非TXT文件"),
              value: filterModel.isShowFile,
              onChanged: (_is) {
                filterModel.setShowFile(_is);
              },
            ),
            CheckboxListTile(
              title: Text("显示以.开头的文件"),
              value: filterModel.isShowDotFile,
              onChanged: (_is) {
                filterModel.setShowDotFile(_is);
              },
            ),
            _rowTitle("排序"),
            _row(Row(
              children: [
                // Expanded(child: _radio(0, "不排序")),
                // Expanded(child: _radio(1, "正序")),
                // Expanded(child: _radio(2, "倒序")),
                _radio(0, "不排序"),
                _radio(1, "正序"),
                _radio(2, "倒序"),
              ],
            ))
          ],
        ),
      ),
    );
  }

  Widget _rowTitle(String title) {
    return Container(
      child: Text(title),
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _row(Widget child) {
    return Container(
      child: child,
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _radio(int curValue, String title) {
    var fn = () {
      setState(() {
        sortValue = curValue;
        filterModel.setSortType(FileItemSortType.values[curValue]);
      });
    };
    return Expanded(
      child: GestureDetector(
        onTap: fn,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title),
            Radio(
              groupValue: sortValue,
              value: curValue,
              onChanged: (dynamic t) {
                fn();
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )
          ],
        ),
      ),
    );
  }
}

Map<FileItemType?, Icon> fileTypeIcon = const {
  null: Icon(Icons.adb),
  FileItemType.dir: Icon(
    Icons.folder_open,
    size: 36,
  ),
  FileItemType.file: Icon(
    Icons.insert_drive_file_outlined,
    size: 36,
  ),
  FileItemType.textFile: Icon(
    Icons.description_rounded,
    size: 36,
  ),
  FileItemType.other: Icon(
    Icons.live_help_outlined,
    size: 36,
  )
};

/// 列表中的每一行(一个文件或文件夹)
/// 单独抽离成一个组件
class _ListItem extends StatefulWidget {
  final FileItem fileItem;
  __FileListWidgetState parent;
  _ListItem(this.fileItem, this.parent, {Key? key})
      : super(key: Key(fileItem.entity.path));

  @override
  _LlistItemState createState() => _LlistItemState(fileItem, parent);
}

class _LlistItemState extends State<_ListItem> {
  /// 文件项目
  final FileItem fileItem;

  /// 上一级
  __FileListWidgetState parent;

  /// 文件大小,转换后的
  String? size;

  /// 当前项是否已经被选中
  bool isSelect = false;

  /// 最后更新时间
  String? time;

  /// 所有书的模型
  BooksModel? booksModel;

  _LlistItemState(this.fileItem, this.parent) {
    size = fileItem.isFile ? NovelUtil.filesize(fileItem.size) + "  " : "";
    time = NovelUtil.date.fullDate(fileItem.updateTime ?? DateTime(0));
  }

  @override
  Widget build(BuildContext context) {
    // print("_LlistItemState--build ${fileItem.name}");
    // 初始化 所有书的模型
    booksModel ??= Provider.of<BooksModel>(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Color(0xFFE6E6E6),
          ),
        ),
      ),
      child: ListTile(
        leading: fileTypeIcon[fileItem.type],
        title: Text(
          fileItem.name,
          style: TextStyle(
            fontSize: 32.w,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              "$size",
              style: TextStyle(fontSize: 24.w),
            ),
            Text(
              "更新时间: $time",
              style: TextStyle(
                fontSize: 20.w,
                background: Paint()..color = Color(0x00FFFFFF),
              ),
            )
          ],
        ),
        trailing: StatefulBuilder(
          builder: (BuildContext context, setState) {
            if (fileItem.type == FileItemType.textFile) {
              // 这里应该有一个从状态中取出数据的操作
              isSelect = booksModel!.includes(path: fileItem.entity.path);
              if (isSelect) {
                return IconButton(
                  icon: Icon(Icons.menu_book),
                  onPressed: () async {
                    //  执行打开电子书的操作
                    print("打开电子书");
                    int t = DateTime.now().millisecondsSinceEpoch;
                    var code = await getFileEncode(path: fileItem.entity.path);
                    print("code:$code");
                    print(11);
                    print("时间:${DateTime.now().millisecondsSinceEpoch - t}");
                  },
                );
              } else {
                return IconButton(
                  icon: Icon(Icons.add_box_outlined),
                  onPressed: () async {
                    // 添加电子书
                    int t = DateTime.now().millisecondsSinceEpoch;
                    var code = await getFileEncode(path: fileItem.entity.path);
                    print("code:$code");
                    print(11);
                    print("时间:${DateTime.now().millisecondsSinceEpoch - t}");
                    FileItem? newFIleItem;
                    if (code == null) {
                      NovelUtil.alertText("无法识别该文件编码类型,",
                          title: "警告", showCancel: false);
                      return;
                    } else if (code == "GBK") {
                      var _is = await NovelUtil.alertText(
                          "该文件为GBK编码,是否将其转换为UTF-8以提升读取性能?",
                          title: "提示");
                      if (_is) {
                        // 将文件保存为UTF8格式,然后替换fileItem
                        var newFile = await saveAsUTF8(fileItem.entity.path);
                        if (newFile != null) {
                          code = "UTF8";
                          newFIleItem = new FileItem(fileItem.entity);
                          newFIleItem.initInfo();
                        } else {
                          NovelUtil.msg("操作失败");
                          return;
                        }
                        print(newFile);
                      }
                      print(_is);
                    }
                    var book = Book.fromFileItem(newFIleItem ?? fileItem);
                    book.encoding = code;
                    booksModel!.add(book);
                    setState(() => isSelect = true);
                    NovelUtil.msg("添加成功!");
                  },
                );
              }
            }
            return Container(
              width: 1,
              height: 1,
            );
          },
        ),
        //长按
        onLongPress: () {
          print("onLongPress");
          // print(controller.offset);
          NovelUtil.alertText("123456", title: "标题11");
        },
        // 点击
        onTap: () async {
          print(fileItem);
          if (fileItem.type == FileItemType.dir) {
            await parent.openDir(fileItem.name);
          } else if (fileItem.type == FileItemType.textFile) {
            BotToast.showText(text: isSelect ? "点击右侧按钮以开始阅读" : "点击右侧加号添加到书架");
            // 添加电子书
            // int t = DateTime.now().millisecondsSinceEpoch;
            // var code = await getFileEncode(path: fileItem.entity.path);
            // var txt = await readTxtFile(path: fileItem.entity.path);
            // print("code=$code,时间:${DateTime.now().millisecondsSinceEpoch - t}");
          } else {
            BotToast.showText(text: "无法对该类型文件进行操作");
          }
        },
      ),
    );
  }
}
