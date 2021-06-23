import 'package:flutter/cupertino.dart';


abstract class SaveChangeNotifier extends ChangeNotifier {
  /// 执行notifyListeners并保存修改到mmkv
  void saveChange() {
    notifyListeners(); //2
    save();
  }

  /// 用于读取数据初始化对象
  Future init([parm]);

  /// 用于保存数据
  Future read();

  /// 用于读取数据初始化对象
  void save();
}
