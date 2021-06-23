import 'package:novel_app/class/page.dart';
import 'package:novel_app/provider/reader_data_model.dart';
import 'package:novel_app/util/split_util.dart';

/// 一个章节的对象
/// 阅读时使用[ReaderChapter]
class Chapter {
  /// 创建章节
  Chapter(this.name, this.start, this.end);

  /// 用一个读取的json数据初始化
  /// 最后决定用数组存储,节省一点空间
  Chapter.fromJson(List list) {
    this.name = list[0];
    this.start = int.parse(list[1]);
    this.end = int.parse(list[2]);
  }

  /// 章节标题
  String name = '';

  /// 章节内容
  String? _content;

  /// 章节开始位置
  int start = 0;

  /// 章节结束为止
  int end = 0;

  /// 章节内容的长度
  int get len => end - start + name.length;

  // 获取章节内容
  String get content {
    if (_content == null) {
      if (ReaderDataModel.txt == null) {
        print("=======================================================");
        print("返回无法读取 $name");
        return '无法读取';
      }
      _content = ReaderDataModel.txt!.substring(start, end);
    }
    return _content!;
  }

  /// 将对象转可以被json序列化的格式
  List<String> toJson() {
    return [name, start.toString(), end.toString()];
  }

  @override
  String toString() {
    return "Chapter{ name: $name,$start ~ $end}";
    // var txt = content.length > 1000 ? content.substring(1000) : content;
    // return "Chapter{ name: $name,$start ~ $end\n${content.length}\n$txt";
  }

  /**
   * 这下面的都是阅读时数据,
   * 存储和展示章节列表用不到这些数据,
   * 只有显示这一章的时候才会初始化这些值
   */

  /// 用JSON初始化,包含阅读时数据
  Chapter.fromReaderDataJson(Map<String, dynamic> map)
      : this.name = map['name'],
        this.start = map['start'],
        this.end = map['end'] {
    /// 初始化list
    if (map['pages'] != null) {
      this._pages = (map['pages'] as List)
          .map<Page>((e) => Page.fromJson(this, e))
          .toList();
    }
    print("fromReaderDataJson==============================");
    print(map);
    print(this._pages);
  }

  /// 这一章的所有页面
  List<Page>? _pages;
  List<Page> get pages {
    if (_pages == null) {
      _pages = SplitUtil.splitPage(chapter: this);
    }
    return _pages!;
  }

  /// 将对象转换成 包含阅读时数据的 可以被json序列化的格式
  ///
  Map<String, dynamic> toReaderDataJson() {
    return {
      "name": name,
      "start": start,
      "end": end,
      /// 这里如果使用_pages,则有可能会保存失败
      /// 调试发现的问题
      /// 原因估计是因为saveChapterContent的调用会先于build,
      /// 所以先保存了,保存的时候还没有初始化值
      "pages": pages.map((page) => page.toJson()).toList()
    };
  }
}
