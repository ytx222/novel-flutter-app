import 'package:novel_app/class/section.dart';
import 'chapter.dart';

/// 阅读中的每一页的数据
class Page {
  /// 初始化章节
  const Page(
    this.sectionList,
    this.index,
    this.chapter
  );
  Page.fromJson(this.chapter, Map<String, dynamic> map)
      : index = map["index"] ?? 0,
        sectionList = (map["sectionList"] as List).map((e) {
          return Section.fromJson((e as Map) as Map<String, dynamic>);
        }).toList();

  final Chapter chapter;

  /// 当前页下标
  final int index;

  /// 当前页的内容
  final List<Section> sectionList;

  Map<String, dynamic> toJson() {
    return {
      "index": index,
      "sectionList": sectionList.map((e) => e.toJson()).toList()
      // "isEnd":isEnd,
    };
  }

  @override
  String toString() {
    return """page {index : $index ,sectionList length:${sectionList.length} }""";
  }
}
