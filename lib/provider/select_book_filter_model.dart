import 'package:flutter/material.dart';

// import 'package:provider/provider.dart';+
enum FileItemSortType {
  ///不排序
  none,

  ///按升序排列 (不用写，默认使用这个)
  asc,

  ///按降序排列
  desc
}

/// 选择电子书页面的筛选条件
class SelectBookFilterModel with ChangeNotifier {
  SelectBookFilterModel();
  /**
   *  是否显示不是txt 的文件
   */
  /// 是否显示不是txt 的文件
  bool _isShowFile = false;

  /// 设置_isShowFile
  void setShowFile(bool? _is) {
    _isShowFile = _is ?? false;
    notifyListeners();
  }

  /// 是否显示不是txt 的文件
  bool get isShowFile => _isShowFile;
  /**
   *  是否显示以.开头的文件
   */
  /// 是否显示以.开头的文件
  bool _isShowDotFile = false;

  /// 设置是否显示以.开头的文件
  void setShowDotFile(bool? _is) {
    _isShowDotFile = _is ?? false;
    notifyListeners();
  }

  /// 是否显示以.开头的文件
  get isShowDotFile => _isShowDotFile;
  /**
   * 排序类型
   */
  /// 排序类型
  FileItemSortType _sortType = FileItemSortType.asc;

  /// 设置排序类型
  void setSortType(FileItemSortType type) {
    _sortType = type;
    notifyListeners();
  }

  /// 排序类型
  get sortType => _sortType;
}
