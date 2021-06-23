/// 存储的一般都是默认设置等
class NovelConfig {
  /// 保存书的内容多少时间后删除(书的文本)
  static Duration bookContentSaveTime = const Duration(seconds: 3 * 60);

  /// 默认的识别电子书文件名的正则
  static RegExp txtRegExp = new RegExp("");

  /// 默认的识别章节名称的正则
  static RegExp chapterRegExp = new RegExp("");

/**
 * 最大字体大小,最小字体大小
 * 阅读页默认安全区大小
 * 默认字体大小
 */
}
