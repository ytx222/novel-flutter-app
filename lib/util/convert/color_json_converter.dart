import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

class ColorJsonConverter implements JsonConverter<Color, int> {
  const ColorJsonConverter();
  @override
  Color fromJson(int json) {
    return Color(json);
  }

  @override
  int toJson(Color object) {
    return object.value;
  }
}
