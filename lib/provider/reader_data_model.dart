import 'dart:async';
import 'dart:convert';

import 'package:novel_app/class/book.dart';
import 'package:novel_app/class/chapter.dart';
import 'package:novel_app/class/save_change_notifier.dart';
import 'package:novel_app/class/section.dart';
import 'package:novel_app/util/file_util.dart';
import 'package:novel_app/util/split_util.dart';
import 'package:novel_app/util/util.dart';
import 'package:novel_app/class/page.dart';

// import 'package:provider/provider.dart';+

/// 阅读-主体数据
const String _readerDataKey = "readerDataKey";

/// 章节列表key
const String _chapterListKey = "readerData_chapterListKey";

/// 最近章节内容key
const String _chapterContentKey = "readerData_chapterContentKey";

/// 当前阅读中的数据
///   当前阅读的那本书的一些数据
///   阅读过程中必要的一些数据
/// 存储当前阅读的数据
/// 包含,所有章节,当前阅读进度,当前章节的内容
class ReaderDataModel extends SaveChangeNotifier {
  ReaderDataModel() {
    initFuture = _isInit.future;
  }
  Completer<void> _isInit = new Completer();
  late Future<void> initFuture;
  bool initEnd = false;

  /// 书对象
  Book? book;

  /// 书的文本内容
  static String? txt;

  /// 加载失败有两种情况,一种是失败,一种是返回了,然后执行了请空数据
  bool isReturn = false;

  /// 初始化
  @override
  Future<Book?> init([parm]) async {
    isReturn = false;
    // 当前逻辑上可能有什么不准确的地方,以至于在初始化未完成的时候initEnd = true,所以这里先设置成false
    initEnd = false;
    // 如果book为null,则认定为恢复模式
    try {
      if (parm == null) {
        this.book = await read();
        if (this.book != null) {
          // 异步的读取内容
          _initChapterList().then((e) {});
        }
      } else {
        // 如果book不是null,则是主动打开这本书的
        this.book = parm;
        this.chapterIndex = parm.chapterIndex ?? 0;

        /// chapterContent改不改应该都一样
        this.chapterContent = [null, null, null];
        await _initChapterList();
        this.setChapter(this.chapterIndex, false);
        // 因为setChapter会修改 page,所以要在这里修改 page
        this.page = parm.pageIndex ?? 0;
        // 手动打开的这本书,则保存一下
        // 同时要调用 notifyListeners 因为截止到现在没有调用过,
        // 这里如果不调用,则无法通知监听model的已经加载完成了
        saveChange(isAll: true);
      }
    } catch (e) {
      print("初始化失败,错误");
      print(e);
      // 返回null,所以将book设置为null
      this.book = null;
    }
    initEnd = true;
    if (!_isInit.isCompleted) _isInit.complete();
    print("阅读数据==init执行完成,返回${this.book}");
    return this.book;
  }

  /// 从mmkv读取数据初始化对象
  /// 读取的时候默认是全部都读取的,因为读取操作应该只会在初始化进行
  Future<Book?> read() async {
    var data = NovelUtil.data.getJsonMap(_readerDataKey);
    if (data.isEmpty) {
      // 如果获取到了空数据,说明被人为删除了,所以返回false初始化失败
      _chapterList = [];
      isReturn = true;
      return null;
    } else {
      try {
        //拿到数据,进行设置数据
        book = new Book.fromMap(data['book']);
        chapterIndex = data['chapterIndex'];
        page = data['page'];
        readChapterContent();
        // 读取章节列表
        var _chapterListData = NovelUtil.data.getJsonList(_chapterListKey);
        _chapterList = _chapterListData.map<Chapter>((e) {
          return Chapter.fromJson(e);
        }).toList();
      } catch (_err) {
        Error err = _err as Error;
        print(err);
        print(err.stackTrace);
      }

      return book;
    }
  }

  /// 执行notifyListeners并保存修改到mmkv
  void saveChange({
    bool isAll = false,
  }) {
    notifyListeners(); //2
    save(isAll: isAll);
  }

  /// 保存对象数据到mmkv
  void save({
    /// 是否保存所有数据(包括章节列表)
    bool isAll = false,
  }) {
    // print("save开始");
    var s = toString(false);
    // print(s);
    NovelUtil.data.setString(_readerDataKey, s);
    if (isAll) {
      /// 章节列表可能是一个比较大的数据,所以单独存储
      // print("保存章节列表开始");
      var chapter = chapterList.map<List<String?>>((chapter) {
        return chapter.toJson();
      }).toList();
      NovelUtil.data.setString(_chapterListKey, json.encode(chapter));
    }
  }

  @override
  String toString([bool isFlull = true]) {
    return json.encode(<String, dynamic>{
      "book": book!.toMap(),
      "chapterIndex": chapterIndex,
      "page": page,
      if (isFlull) "最近章节内容": chapterContent,
      if (isFlull) "章节列表": chapter,
    });
  }

  /// 读取当前章节的文本内容
  void readChapterContent() {
    // 读取最近章节内容
    var _chapterContentData = NovelUtil.data.getJsonList(_chapterContentKey);
    chapterContent = _chapterContentData.map<Chapter?>((e) {
      if (e == null) {
        // 不能是空的吧
        return null;
      }
      return Chapter.fromReaderDataJson(e);
    }).toList();
  }

  /// 保存可以保存到book的信息,并将book返回,用于退出阅读页面时保存进度
  Book? saveAsBook() {
    try {
      Book b = book!;
      b.lastReaderTime = DateTime.now();
      b.chapterIndex = chapterIndex;
      b.chapterLength = chapterLength;
      b.lastChapterName = curPage.chapter.name;
      b.pageIndex = page;
      // FIXME: 自定义正则,还没做
      return b;
    } catch (e) {
      return null;
    }
  }

  /// 保存当前章节的文本内容
  void saveChapterContent() {
    var _chapterContent = chapterContent.map((e) {
      if (e != null) {
        return e.toReaderDataJson();
      }
      return null;
    }).toList();
    NovelUtil.data.setString(_chapterContentKey, json.encode(_chapterContent));
  }

  /// 删除保存的数据
  void reset() {
    ReaderDataModel.txt = null;
    _isInit = new Completer();
    initFuture = _isInit.future;
    initEnd = false;

    NovelUtil.data
      ..delete(_readerDataKey)
      ..delete(_chapterListKey)
      ..delete(_chapterContentKey);
  }

  /// 所有章节
  List<Chapter>? _chapterList;

  /// 获取章节列表,如果不存在时,返回空数组
  List<Chapter> get chapterList => _chapterList ?? <Chapter>[];

  /// 获取章节数量
  int get chapterLength => _chapterList?.length ?? 0;

  /// 获取章节列表
  Future<List<Chapter>?> getChapterList() async {
    print("getChapterList");
    print(_chapterList);
    if (_chapterList == null || chapterList.isEmpty) {
      await _initChapterList();
      //  notifyListeners();
    }
    return _chapterList;
  }

  /// 初始化章节列表
  Future<void> _initChapterList() async {
    print("_initChapterLis");
    // 先获取文本内容
    if (ReaderDataModel.txt == null) {
      var txt =
          await readTxtFileASync(path: book!.path, encoding: book!.encoding);
      if (txt == null) {
        throw new Exception("读取txt失败");
      }
      ReaderDataModel.txt = txt;
    } else {
      // print("_initChapterLis -- 有内容,跳过初始化");
    }
    _chapterList = await SplitUtil.splitChapterASync(ReaderDataModel.txt!);
  }

  /// 当前阅读的章节对象
  Chapter? get chapter {
    print('获取chapter-$chapterIndex');

    // print(_chapterList);
    // print(_chapter);
    if (chapterList.isEmpty) {
      print("返回null");
      return null;
    }
    print(chapterList[chapterIndex]);
    return chapterList[chapterIndex];
  }

  ///当前阅读到第几章
  int chapterIndex = 0;

  /// 修改当前阅读到第几章
  // void setChapterIndex(index) {
  //   print("setChapterIndex 调用 $chapterIndex");
  //   chapterIndex = index;
  //   saveChange();
  // }

  /// 最近三章的章节内容
  /// 这个数值的长度在初始化后永远是三
  /// 在第一章是上一章是null 在最后一章时下一章是null
  List<Chapter?> chapterContent = [null, null, null];

  /// 刷新章节内容,()用于设置修改后重新计算
  void refreshChapterContent() {
    // 按照比例吧
    double v = page / pageNum;
    setChapter(chapterIndex, false);
    int newPage = (v * pageNum).round();
    setPage(newPage);
  }

  /**
   *
   * 由于最后一章和第一章时,再翻章没有内容显示
   * 也不能再翻章
   * 所以不设置为null了
   * 先这样吧
   */
  /// 下一章
  bool nextChapter() {
    if (chapterIndex == chapterLength - 1) return false;
    print("=========执行下一章");
    // 删除上一章并添加下下章,当前章自动变成下一章
    if (chapterIndex < chapterLength - 2) {
      chapterContent.removeAt(0);
      chapterContent.add(chapterList[chapterIndex + 2]);
    }
    page = 0;
    chapterIndex++;
    // curchapterContentIndex = (curchapterContentIndex + 1) % 3;

    saveChange();
    saveChapterContent();
    return true;
  }

  /// 上一章
  /// [pageChange] 是否是翻页所引发的,如果是则需要跳转到最后一页
  bool prevChapter([bool pageChange = true]) {
    if (chapterIndex == 0) return false;
    print("=========执行上一章");
    // 删除下一章并添加上上章,当前章自动变成上一章
    if (chapterIndex > 1) {
      chapterContent.removeLast();
      chapterContent.insert(0, chapterList[chapterIndex - 2]);
    }
    // 如果是翻页的,跳到最后一页,否则第一页
    page = pageChange ? pageNum : 0;
    chapterIndex--;
    saveChange();
    saveChapterContent();
    return true;
  }

  /// 跳转到某一章
  void setChapter(int index, [bool save = true]) {
    print(
        " ============================================================================================= ");
    print("setChapter-$index");
    chapterIndex = index;
    // curchapterContentIndex = 1;

    ///FIXME: 跳转章节是只能设置到第一页的,但是上一章需要跳转到最后一页
    page = 0;
    // 初始化当前章节
    curChapterData = chapterList[index];
    // 如果有上一章,则初始化上一章
    prevChapterData = index > 0 ? chapterList[index - 1] : null;

    // 如果有下一章,则初始化下一章
    nextChapterData =
        index < chapterLength ? nextChapterData = chapterList[index + 1] : null;
    print(prevChapterData);
    print(curChapterData);
    print(nextChapterData);
    print(chapterContent);
    if (save) {
      //因为只需要保存章节的修改,所以不能直接调用saveChange
      notifyListeners();
      saveChapterContent();
    }
  }

  /// 当前章节的页面
  Chapter? get curChapterData => chapterContent[1];
  set curChapterData(Chapter? v) => chapterContent[1] = v;

  /// 当前章节的页面
  Chapter? get prevChapterData => chapterContent[0];
  set prevChapterData(Chapter? v) => chapterContent[0] = v;

  /// 当前章节的页面
  Chapter? get nextChapterData => chapterContent[2];
  set nextChapterData(Chapter? v) => chapterContent[2] = v;

  int get pageNum {
    if (curChapterData?.pages == null) {
      return 0;
    }
    return curChapterData!.pages.length - 1;
  }

  ///当前阅读到第几页(某一章的第几页)
  int page = -2;

  /// 修改当前阅读到第几页
  void setPage(page) {
    print("setPage 调用 $page");
    this.page = page;
    saveChange();
  }

  /// 当前页面
  Page get curPage {
    try {
      return curChapterData!.pages[page];
    } catch (e) {
      // 如果出错了,则返回错误提示
      return Page([
        Section("404", isTitle: true),
        Section("出错了"),
        Section("因为读取的这个页面并不存在"),
        Section("$e"),
      ], 0, Chapter('404', 0, 0));
    }
  }

  /// 上一页
  Page get prevPage {
    try {
      if (page == 0) {
        return prevChapterData!.pages.last;
      }
      return curChapterData!.pages[page - 1];
    } catch (e) {
      // 如果出错了,则返回错误提示
      return Page([
        Section("404", isTitle: true),
        Section("出错了"),
        Section("因为读取的这个页面并不存在"),
        Section("$e"),
      ], 0, Chapter('404', 0, 0));
    }
  }

  /// 下一页
  Page get nextPage {
    try {
      if (page == pageNum) {
        return nextChapterData!.pages.first;
      }
      return curChapterData!.pages[page + 1];
    } catch (e) {
      // 如果出错了,则返回错误提示
      return Page([
        Section("404", isTitle: true),
        Section("出错了"),
        Section("因为读取的这个页面并不存在"),
        Section("$e"),
      ], 0, Chapter('404', 0, 0));
    }
  }

  // 这个是完全的运行时数据,不需要保存
  /// 系统电量,只显示
  int battery = 0;

  void setBattery(int v) {
    battery = v;
    // 只通知,不保存
    notifyListeners();
  }
}
