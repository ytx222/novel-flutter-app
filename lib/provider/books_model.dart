import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:novel_app/class/book.dart';
import 'package:novel_app/util/util.dart';

const String booksKey = "books";

// import 'package:provider/provider.dart';+
/// 所有电子书
class BooksModel with ChangeNotifier {
  BooksModel() {
    //
  }
  List<Book>? _list;

  List<Book> get list {
    if (_list == null) {
      initList();
    }
    return _list!;
  }

  /// 初始化书列表
  initList() {
    print("initList");
    List l = NovelUtil.data.getJsonList(booksKey);
    _list = l.map<Book>((item) {
      return Book.fromMap(item as Map<String, dynamic>);
    }).toList();
    print("初始化完成,共${_list!.length}项");
  }

  /// 将当前书列表保存
  void save() {
    var list = toListMap();
    NovelUtil.data.setString(booksKey, json.encode(list));
    print(NovelUtil.data
        .getJsonList(booksKey)
        .map<String>((e) {
          return (e as Map)["name"];
        })
        .toList()
        .toString());
  }

  /// 转换为List<Map<String, dynamic>>格式,用于json格式化
  List<Map<String, dynamic>> toListMap() {
    return _list!.map<Map<String, dynamic>>((book) => book.toMap()).toList();
  }

  /// 添加一本书
  void add(Book book) {
    print("添加一本书到书架");
    print(book);
    _list!.add(book);
    save();
    notifyListeners();
  }

  /// 删除一本书
  bool remove(Book book) {
    var _is = _list!.remove(book);
    if (_is) {
      save();
      notifyListeners();
    }
    return _is;
  }

  ///  获取map类型的书本列表
  /// [key] map中以 path 还是以 fileName 为键
  Map<String, Book> getMap({String key = "path"}) {
    var map = _list!.asMap().map<String, Book>((i, v) {
      return MapEntry(key == "path" ? v.path : v.fileName, v);
    });
    return map;
  }

  /// 当前书列表中是否包含指定书
  /// [path] 书的路径
  /// [name] 书名
  bool includes({String? path, String? name}) {
    var el = list.firstWhereOrNull((Book book) {
      if (book.path == path || book.name == name) {
        return true;
      } else {
        return false;
      }
    });
    return el != null;
  }
}
