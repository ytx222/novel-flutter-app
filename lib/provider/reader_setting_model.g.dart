// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reader_setting_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReaderSettingModel _$ReaderSettingModelFromJson(Map<String, dynamic> json) {
  return ReaderSettingModel()
    ..backgroundColor =
        const ColorJsonConverter().fromJson(json['backgroundColor'] as int)
    ..fontSize = (json['fontSize'] as num).toDouble()
    ..lineHeight = (json['lineHeight'] as num).toDouble()
    ..titleFontSize = (json['titleFontSize'] as num).toDouble()
    ..titleLineHeight = (json['titleLineHeight'] as num).toDouble()
    ..sectionSpace = (json['sectionSpace'] as num).toDouble()
    ..color = const ColorJsonConverter().fromJson(json['color'] as int)
    ..indent = json['indent'] as int
    ..headerTopOffset = (json['headerTopOffset'] as num).toDouble()
    ..headerLeftOffset = (json['headerLeftOffset'] as num).toDouble()
    ..headerRightOffset = (json['headerRightOffset'] as num).toDouble()
    ..footerBottomOffset = (json['footerBottomOffset'] as num).toDouble()
    ..footerHorizontalOffset =
        (json['footerHorizontalOffset'] as num).toDouble()
    ..contentHorizontalPadding =
        (json['contentHorizontalPadding'] as num).toDouble()
    ..contentToplPadding = (json['contentToplPadding'] as num).toDouble()
    ..contentBottomlPadding = (json['contentBottomlPadding'] as num).toDouble()
    ..turnAnimationType = _$enumDecodeNullable(
            _$TurnAnimationTypeEnumMap, json['turnAnimationType']) ??
        TurnAnimationType.cover;
}

Map<String, dynamic> _$ReaderSettingModelToJson(ReaderSettingModel instance) =>
    <String, dynamic>{
      'backgroundColor':
          const ColorJsonConverter().toJson(instance.backgroundColor),
      'fontSize': instance.fontSize,
      'lineHeight': instance.lineHeight,
      'titleFontSize': instance.titleFontSize,
      'titleLineHeight': instance.titleLineHeight,
      'sectionSpace': instance.sectionSpace,
      'color': const ColorJsonConverter().toJson(instance.color),
      'indent': instance.indent,
      'headerTopOffset': instance.headerTopOffset,
      'headerLeftOffset': instance.headerLeftOffset,
      'headerRightOffset': instance.headerRightOffset,
      'footerBottomOffset': instance.footerBottomOffset,
      'footerHorizontalOffset': instance.footerHorizontalOffset,
      'contentHorizontalPadding': instance.contentHorizontalPadding,
      'contentToplPadding': instance.contentToplPadding,
      'contentBottomlPadding': instance.contentBottomlPadding,
      'turnAnimationType':
          _$TurnAnimationTypeEnumMap[instance.turnAnimationType],
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$TurnAnimationTypeEnumMap = {
  TurnAnimationType.cover: 'cover',
  TurnAnimationType.simulation: 'simulation',
  TurnAnimationType.slide: 'slide',
  TurnAnimationType.none: 'none',
};
