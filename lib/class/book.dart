import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:novel_app/util/file_util.dart';

part 'book.g.dart';

/// 一本书的数据对象
/// 注意,这只是数据对象,实际和阅读有关的是ReaderDataModel对象
@JsonSerializable()
class Book {
  /// txt文件在本机的路径
  String path = '';

  /// 文件大小
  int size = 0;

  /// 书的文件名,应该是path的末尾+.txt
  String fileName = '';

  /// 书的名称,可以修改,默认是文件名
  String name = '';

  /// 编码 null | UFT8 | GBK
  String? encoding;

  /**
   * 做阅读进度的同时丰富一下书的数据
   * 部分参数好像不能做?
   */
  /// 添加到书架的时间
  DateTime? createTime;

  /**
   * 下面的时和阅读进度相关的值,全部为可空的,
   */
  /// 上次阅读时间
  DateTime? lastReaderTime;

  /// 章节进度
  int? chapterIndex;

  /// 章节数量
  int? chapterLength;

  /// 最后阅读的章节的名称
  String? lastChapterName;

  /// 页面进度
  int? pageIndex;

  /// 自定义正则
  String? customRegex;

  /// 直接初始化
  Book(
    this.fileName,
    this.name,
    this.path,
    this.size, {
    this.encoding,
  }) {
    if (this.name.length == 0) {
      this.name = this.fileName.substring(0, this.fileName.length - 4);
    }
  }

  /// 只根据地址创建一本书的对象,其他数据读取
  // Book.fromPath(this.path) {
  //   //...
  // }

  /// 根据一个FileItem对象初始化
  Book.fromFileItem(FileItem data) {
    this.fileName = data.name;

    if (data.name.endsWith(".txt")) {}
    this.name = data.name.endsWith(".txt")
        ? data.name.substring(0, data.name.length - 4)
        : data.name;
    this.path = data.entity.path;
    this.size = data.size;
  }

  /// 根据一个FileItem对象初始化
  factory Book.fromMap(Map<String, dynamic> json) {
    return _$BookFromJson(json);
    // var bookData = data as Map<String, dynamic>;
    // fileName = bookData["fileName"]!;
    // path = bookData["path"]!;
    // name = bookData["name"]!;
    // size = bookData["size"]!;
    // encoding = bookData["encoding"]!;
  }

  Map<String, dynamic> toMap() {
    return _$BookToJson(this);
  }

  @override
  String toString() {
    return "Book:" + json.encode(toMap());
  }

  bool operator ==(Object b2) {
    if (b2 is Book) {
      if (this.path == b2.path && this.size == b2.size) {
        return true;
      }
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode;
}

/// 书架
class Bookrack {}
