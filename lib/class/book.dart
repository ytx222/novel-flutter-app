import 'dart:convert';

import 'package:novel_app/util/file_util.dart';

/// 一本书的数据对象
/// 注意,这只是数据对象,实际和阅读有关的是ReaderDataModel对象
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
  Book.fromMap(Map data) {
    var bookData = data as Map<String, dynamic>;
    fileName = bookData["fileName"]!;
    path = bookData["path"]!;
    name = bookData["name"]!;
    size = bookData["size"]!;
    encoding = bookData["encoding"]!;
  }

  Map<String, dynamic> toMap() {
    return {
      "fileName": fileName,
      "path": path,
      "size": size,
      "name": name,
      'encoding': encoding
    };
  }

  @override
  String toString() {
    return "Book:" + json.encode(toMap());
  }
}

/// 书架
class Bookrack {}
