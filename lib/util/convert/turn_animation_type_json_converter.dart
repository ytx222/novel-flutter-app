import 'package:json_annotation/json_annotation.dart';
import 'package:novel_app/provider/reader_setting_model.dart';

class TurnAnimationTypeJsonConverter
    implements JsonConverter<TurnAnimationType, String> {
  const TurnAnimationTypeJsonConverter();
  @override
  TurnAnimationType fromJson(String s) {
    switch (s) {
      case '覆盖':
        return TurnAnimationType.cover;
      case '仿真':
        return TurnAnimationType.simulation;
      case '滑动':
        return TurnAnimationType.slide;
      case '无':
        return TurnAnimationType.none;
      default:
        return TurnAnimationType.none;
    }
  }

  @override
  String toJson(TurnAnimationType type) {
    switch (type) {
      case TurnAnimationType.cover:
        return '覆盖';
      case TurnAnimationType.simulation:
        return '仿真';
      case TurnAnimationType.slide:
        return '滑动';
      case TurnAnimationType.none:
        return '无';
      default:
        return '';
    }
  }
}
