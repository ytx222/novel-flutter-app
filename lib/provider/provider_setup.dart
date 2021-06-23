import 'package:novel_app/provider/reader_data_model.dart';
import 'package:novel_app/provider/reader_setting_model.dart';
import 'package:novel_app/provider/select_book_filter_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'books_model.dart';


/*
/// 当前阅读的书,阅读核心逻辑之一
var _ReaderDataModel =ReaderDataModel();

/// 阅读设置
var _readerSettingModel = ReaderSettingModel();

/// 所有书
var _booksModel = BooksModel();

/// 选择文件页面,筛选规则
var _filterModel = SelectBookFilterModel();
*/
// SingleChildWidget
List<SingleChildStatelessWidget> providers = [
  // 阅读设置
  // 官方文档说不使用.value
  // Provider<ReaderSettingModel>.value(value: ReaderSettingModel()),
  // Provider<ReaderSettingModel>(
  //   create: (_) => ReaderSettingModel(),
  // ),
  // 改变
  ChangeNotifierProvider(create: (_) =>  ReaderDataModel()),
  ChangeNotifierProvider(create: (_) =>  ReaderSettingModel.fromMMKV()),
  ChangeNotifierProvider(create: (_) =>  BooksModel()),
  ChangeNotifierProvider(create: (_) =>  SelectBookFilterModel()),

  // ChangeNotifierProvider<ReaderSettingModel>.value(
  //   value: _readerSettingModel,
  // ),
  // ChangeNotifierProvider<BooksModel>.value(
  //   value: _booksModel,
  // ),
  // ChangeNotifierProvider<SelectBookFilterModel>.value(
  //   value: _filterModel,
  // ),

  // ProxyProvider<NovelApi, NovelBookNetModel>(
  //   update: (context, api, netModel) => NovelBookNetModel(api),
  // ),
];
/*
复用一个已存在的对象实例:
如果你已经拥有一个对象实例并且想暴露出它，你应当使用一个provider的.value构造函数。
如果你没有这么做，那么在你调用对象的 dispose 方法时， 这个对象可能仍然在被使用。
使用ChangeNotifierProvider.value来提供一个当前已存在的 ChangeNotifier
MyChangeNotifier variable;
ChangeNotifierProvider.value(
  value: variable，
  child: ...
)
!!!!!!!!!
不要使用默认的构造函数来尝试复用一个已存在的 ChangeNotifier
MyChangeNotifier variable;
ChangeNotifierProvider(
  create: (_) => variable，
  child: ...
)


如果你想将随时间改变的变量传入给对象，请使用ProxyProvider:
int count;
ProxyProvider0(
  update: (_， __) => MyModel(count)，
  child: ...
)
// ProxyProvider<NovelApi, NovelBookNetModel>(
//  update: (context, api, netModel) => NovelBookNetModel(api),
//),

*/
