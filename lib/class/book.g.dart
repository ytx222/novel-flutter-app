// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) {
  return Book(
    json['fileName'] as String,
    json['name'] as String,
    json['path'] as String,
    json['size'] as int,
    encoding: json['encoding'] as String?,
  )
    ..createTime = json['createTime'] == null
        ? null
        : DateTime.parse(json['createTime'] as String)
    ..lastReaderTime = json['lastReaderTime'] == null
        ? null
        : DateTime.parse(json['lastReaderTime'] as String)
    ..chapterIndex = json['chapterIndex'] as int?
    ..chapterLength = json['chapterLength'] as int?
    ..lastChapterName = json['lastChapterName'] as String?
    ..pageIndex = json['pageIndex'] as int?
    ..customRegex = json['customRegex'] as String?;
}

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
      'path': instance.path,
      'size': instance.size,
      'fileName': instance.fileName,
      'name': instance.name,
      'encoding': instance.encoding,
      'createTime': instance.createTime?.toIso8601String(),
      'lastReaderTime': instance.lastReaderTime?.toIso8601String(),
      'chapterIndex': instance.chapterIndex,
      'chapterLength': instance.chapterLength,
      'lastChapterName': instance.lastChapterName,
      'pageIndex': instance.pageIndex,
      'customRegex': instance.customRegex,
    };
