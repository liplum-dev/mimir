import 'dart:ui';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/utils/byte_io/byte_io.dart';

part "dual_color.g.dart";

int _colorToJson(Color color) => color.value;

Color _colorFromJson(int value) => Color(value);

@JsonSerializable()
@CopyWith(skipFields: true)
class ColorEntry {
  @JsonKey(toJson: _colorToJson, fromJson: _colorFromJson)
  final Color color;
  final bool inverseText;

  const ColorEntry(
    this.color, {
    this.inverseText = false,
  });

  const ColorEntry.inverse(
    this.color,
  ) : inverseText = true;

  factory ColorEntry.fromJson(Map<String, dynamic> json) => _$ColorEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ColorEntryToJson(this);

  void serialize(ByteWriter writer) {
    writer.uint32(color.value);
    writer.b(inverseText);
  }

  factory ColorEntry.deserialize(ByteReader reader) {
    return ColorEntry(
      Color(reader.uint32()),
      inverseText: reader.b(),
    );
  }
}

@JsonSerializable()
@CopyWith(skipFields: true)
class DualColor {
  final ColorEntry light;
  final ColorEntry dark;

  const DualColor({
    required this.light,
    required this.dark,
  });

  DualColor.plain({
    required Color light,
    required Color dark,
  })  : light = ColorEntry(light),
        dark = ColorEntry(dark);

  factory DualColor.fromJson(Map<String, dynamic> json) => _$DualColorFromJson(json);

  Map<String, dynamic> toJson() => _$DualColorToJson(this);

  void serialize(ByteWriter writer) {
    light.serialize(writer);
    dark.serialize(writer);
  }

  factory DualColor.deserialize(ByteReader reader) {
    return DualColor(
      light: ColorEntry.deserialize(reader),
      dark: ColorEntry.deserialize(reader),
    );
  }
}

extension ColorEntryX on ColorEntry {
  Color textColor(BuildContext context) =>
      inverseText ? context.colorScheme.onInverseSurface : context.colorScheme.onSurface;
}

extension DualColorX on DualColor {
  ColorEntry byBrightness(Brightness brightness) => brightness == Brightness.dark ? dark : light;

  ColorEntry byContext(BuildContext context) => context.isDarkMode ? dark : light;

  Color colorBy(BuildContext context) => (context.isDarkMode ? dark : light).color;

  Color textColorBy(BuildContext context) => (context.isDarkMode ? dark : light).textColor(context);
}
