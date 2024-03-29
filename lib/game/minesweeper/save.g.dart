// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cell4Save _$Cell4SaveFromJson(Map<String, dynamic> json) => Cell4Save(
      mine: json['mine'] as bool? ?? false,
      state: $enumDecodeNullable(_$CellStateEnumMap, json['state']) ?? CellState.covered,
    );

Map<String, dynamic> _$Cell4SaveToJson(Cell4Save instance) => <String, dynamic>{
      'mine': instance.mine,
      'state': _$CellStateEnumMap[instance.state]!,
    };

const _$CellStateEnumMap = {
  CellState.covered: 0,
  CellState.blank: 1,
  CellState.flag: 2,
};

SaveMinesweeper _$SaveMinesweeperFromJson(Map<String, dynamic> json) => SaveMinesweeper(
      rows: json['rows'] as int? ?? 15,
      columns: json['columns'] as int? ?? 8,
      cells: (json['cells'] as List<dynamic>?)?.map((e) => Cell4Save.fromJson(e as Map<String, dynamic>)).toList() ??
          _defaultCells(),
    );

Map<String, dynamic> _$SaveMinesweeperToJson(SaveMinesweeper instance) => <String, dynamic>{
      'rows': instance.rows,
      'columns': instance.columns,
      'cells': instance.cells,
    };
