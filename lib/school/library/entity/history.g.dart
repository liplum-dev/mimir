// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchHistoryItem _$SearchHistoryItemFromJson(Map<String, dynamic> json) => SearchHistoryItem(
      keyword: json['keyword'] as String,
      searchMethod: $enumDecode(_$SearchMethodEnumMap, json['searchMethod']),
      time: DateTime.parse(json['time'] as String),
    );

Map<String, dynamic> _$SearchHistoryItemToJson(SearchHistoryItem instance) => <String, dynamic>{
      'keyword': instance.keyword,
      'searchMethod': _$SearchMethodEnumMap[instance.searchMethod]!,
      'time': instance.time.toIso8601String(),
    };

const _$SearchMethodEnumMap = {
  SearchMethod.any: 'any',
  SearchMethod.title: 'title',
  SearchMethod.primaryTitle: 'primaryTitle',
  SearchMethod.isbn: 'isbn',
  SearchMethod.author: 'author',
  SearchMethod.subject: 'subject',
  SearchMethod.$class: r'$class',
  SearchMethod.bookId: 'bookId',
  SearchMethod.orderNumber: 'orderNumber',
  SearchMethod.publisher: 'publisher',
  SearchMethod.callNumber: 'callNumber',
};
