///
/// 阅读中的每一个段落
class Section {
  /// 初始化段落
  const Section(
    this.text, {
    this.isStart = true,
    this.isTitle = false,
    this.index = -2,
    this.isSpace = true,
  });

  /// 用json数据初始化
  Section.fromJson(Map<String, dynamic> map)
      : text = map['text'],
        isTitle = map['isTitle'],
        isStart = map['isStart'],
        index = map['index'],
        isSpace = map['isSpace'] ?? false;

  /// 段落内容
  final String text;

  /// 段落是否是标题
  final bool isTitle;

  /// 段落是不是开始的,如果不是,代表因为分页段落被中断了
  final bool isStart;

  /// 是否有间距
  /// 在代码中实际表现为上边距,目前规则为,
  ///   每页开头无上边距
  final bool isSpace;

  /// 段落下标,
  /// -2 是默认值
  /// -1 是标题
  /// 剩下的是正常下标 0 ~ n
  final int index;

  Map<String, dynamic> toJson() {
    var map = {
      "text": text,
      "isTitle": isTitle,
      "isStart": isStart,
      "isSpace": isSpace,
      "index": index,
    };
    return map;
  }
}
