import 'package:flutter/material.dart';
import 'package:novel_app/class/book.dart';
import 'package:novel_app/components/pageWidget.dart';
import 'package:novel_app/provider/books_model.dart';
import 'package:novel_app/util/util.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 书架页面
class BookrackPage extends PageWidget {
  final Map<String, Object>? args;
  BookrackPage({this.args, Key? key}) : super(key: key);

  @override
  _BookrackPageState createState() => _BookrackPageState(args: this.args);
}

class _BookrackPageState extends State<BookrackPage> {
  /// 创建书架
  _BookrackPageState({this.args});

  /// 参数
  final Map<String, Object>? args;

  /// 所有书的模型
  late BooksModel booksModel;

  /// 系统状态栏高度
  double? stateHeigth;

  /// 获取所有书
  List<Widget> getBooks() {
    // print("getBooks");
    // print(booksModel.list);
    var list = booksModel.list.map<_BookrackItem>((book) {
      return _BookrackItem(book: book);
    }).toList();
    print(list);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    booksModel = Provider.of<BooksModel>(context);
    stateHeigth ??= MediaQuery.of(context).padding.top;

    print("stateHeigth: $stateHeigth");

    // MediaQueryData a = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(title: Text("书架"), actions: [
        IconButton(
          icon: Icon(
            const IconData(0xe663, fontFamily: "iconfont"),
            color: Color(0xFF666666),
            size: 40.w,
          ),
          onPressed: () {
            Navigator.pushNamed(context, "/file/selectBook");
          },
        ),
        IconButton(
          icon: Icon(
            const IconData(0xe687, fontFamily: "iconfont"),
            color: Color(0xFF666666),
            size: 40.w,
          ),
          onPressed: () {
            NovelUtil.alertText('暂未实现,以后可能放点设置之类的吧');
          },
        )
      ]),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20.w,
              ),
              Visibility(
                visible: false,
                child: Container(
                  // color: Color(0xFF28A828),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          // color: Color(0xFF8F3E3E),
                          child: Text("1"),
                        ),
                      ),
                      Container(
                        // color: Color(0xFF5F8BC4),
                        height: 40.h,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/file/selectBook");
                          },
                          style: ButtonStyle(
                            padding:
                                ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(
                              EdgeInsets.all(0),
                            ),
                          ),
                          child: Text(
                            "选择文件",
                            style: TextStyle(height: 1),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 30.w,
                  // vertical: 40.w,
                ),
                child: Wrap(
                  children: getBooks(),
                ),
              ),
              Container(
                child: TextButton(
                  onPressed: () {
                    NovelUtil.alertText("""
作者网站: ytx222.com
github: github.com/ytx222
本项目地址: ytx222/novel-flutter-app
欢迎star
另有vscode阅读插件,数独游戏(带解密)等 """,
height: 480.w);
                  },
                  child: Text('作者: ytx222'),
                ),
              ),
              SizedBox(height: 50.w,)
            ],
          ),
        ),
      ),
    );
  }
}

/// 书架中的每一个项目
class _BookrackItem extends StatelessWidget {
  final Book book;

  /// 所有书的模型
  // late BooksModel booksModel;

  _BookrackItem({Key? key, required this.book}) : super(key: key) {
    // this.name = book.name;
  }

  @override
  Widget build(BuildContext context) {
    var booksModel = Provider.of<BooksModel>(context);
    return Container(
      margin: EdgeInsets.all(10.w),
      width: 210.w,
      height: 320.w,
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(
            0xFFCCCCCC,
          ),
        ),
      ),
      child: btnContainer(
        context: context,
        booksModel: booksModel,
        child: Container(
          width: 190.w,
          height: 300.w,
          padding: EdgeInsets.all(10.w),
          color: Color(0xFFE7E7E7),
          // 书皮
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.name,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 24.w,
                ),
              ),
              SizedBox(height: 10.w),
              Text(
                NovelUtil.filesize(book.size),
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 24.w,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 20.w),
              Text(
                "0%",
                style: TextStyle(
                  color: Color(0xFF444444),
                  fontSize: 28.w,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget btnContainer({
    required BuildContext context,
    required BooksModel booksModel,
    required Widget child,
  }) {
    return TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
          EdgeInsets.all(10.w),
        ),
      ),
      onPressed: () {
        print("点击--${book.name}");
        Navigator.pushNamed(context, "/reader", arguments: {"book": book});
      },
      onLongPress: () {
        print("长按一本书");
        alert(context, booksModel);
        print(book);
      },
      child: child,
    );
  }

  void alert(
    BuildContext context,
    BooksModel booksModel,
  ) {
    Function? cancelFunc;
    NovelUtil.alert(
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                child: Text("删除"),
                onPressed: () {
                  booksModel.remove(book);
                  if (cancelFunc != null) {
                    cancelFunc!();
                  }
                },
              ),
            ],
          ),
        ),
        title: "操作",
        height: 400,
        getCancelFunc: (_cancelFunc) {
          cancelFunc = _cancelFunc;
        });
  }
}
