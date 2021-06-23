import 'package:flutter/cupertino.dart';

abstract class PageWidget extends StatefulWidget {
  /// 接收的参数
  @required
  final Map<String, Object>? args;

  /// 指定构造方法必须有args参数
  PageWidget({this.args, Key? key});
}
