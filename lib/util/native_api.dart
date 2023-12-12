import 'package:flutter/services.dart';

class NativeApi {
  /// 通道
  /// FIXME:
  static const platform = const MethodChannel('com.ytx222.novel_app3.api');
  // Get battery level.
  /// 获取电池电量,亲测成功
  static Future<int> getBatteryLevel() async {
    try {
      int result = await platform.invokeMethod('getBattery') ?? 0;
      return result;
    } on PlatformException catch (e) {
      print(e);
      return -1;
    }
  }

  /// 设置音量拦截
  static Future<void> setVolumeIntercept(bool _is) async {
    try {
      await platform.invokeMethod('setVolumeChangeObserver', _is);
    } on PlatformException catch (e) {
      print(e);
      print("设置音量拦截 出错");
    }
  }

  /// 设置电池电量监听
  static Future<void> setBatteryChangeObserver(bool _is) async {
    try {
      await platform.invokeMethod('setBatteryChangeObserver', _is);
    } on PlatformException catch (e) {
      print(e);
      print("设置电池电量监听 出错");
    }
  }
}
