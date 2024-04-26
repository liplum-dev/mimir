import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sit/files.dart';
import 'package:sit/timetable/entity/background.dart';

class TimetableBackground extends StatelessWidget {
  final BackgroundImage background;
  final bool fade;
  final ValueListenable<double>? verticalOffset;
  final Duration fadeDuration;

  const TimetableBackground({
    super.key,
    required this.background,
    this.fade = true,
    this.fadeDuration = Durations.long2,
    this.verticalOffset,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _TimetableBackgroundWebImpl(
        background: background,
      );
    } else {
      return _TimetableBackgroundImpl(
        background: background,
        fade: fade,
        fadeDuration: kDebugMode ? const Duration(milliseconds: 1000) : Durations.long1,
        verticalOffset: verticalOffset,
      );
    }
  }
}

class _TimetableBackgroundImpl extends StatefulWidget {
  final BackgroundImage background;
  final bool fade;
  final Duration fadeDuration;
  final ValueListenable<double>? verticalOffset;

  const _TimetableBackgroundImpl({
    required this.background,
    this.fade = true,
    this.fadeDuration = Durations.long2,
    this.verticalOffset,
  });

  @override
  State<_TimetableBackgroundImpl> createState() => _TimetableBackgroundImplState();
}

class _TimetableBackgroundImplState extends State<_TimetableBackgroundImpl> with SingleTickerProviderStateMixin {
  late final AnimationController $opacity;

  @override
  void initState() {
    super.initState();
    $opacity = AnimationController(vsync: this, value: widget.fade ? 0.0 : widget.background.opacity);
    if (widget.fade) {
      $opacity.animateTo(
        widget.background.opacity,
        duration: widget.fadeDuration,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    $opacity.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _TimetableBackgroundImpl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fade && oldWidget.fade) {
      if (oldWidget.background != widget.background) {
        if (oldWidget.background.path != widget.background.path) {
          $opacity.value = 0.0;
        }
        $opacity.animateTo(
          widget.background.opacity,
          duration: widget.fadeDuration,
          curve: Curves.easeInOut,
        );
      }
    } else {
      $opacity.value = widget.background.opacity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final verticalOffset = widget.verticalOffset;
    if (verticalOffset != null) {
      return AnimatedBuilder(
        animation: verticalOffset,
        builder: (context, _) {
          return buildImage(align: Alignment(0, verticalOffset.value));
        },
      );
    } else {
      return buildImage();
    }
  }

  Widget buildImage({
    Alignment align = Alignment.center,
  }) {
    final background = widget.background;
    return Image.file(
      Files.timetable.backgroundFile,
      opacity: $opacity,
      alignment: align,
      filterQuality: background.filterQuality,
      repeat: background.imageRepeat,
    );
  }
}

class _TimetableBackgroundWebImpl extends StatelessWidget {
  final BackgroundImage background;

  const _TimetableBackgroundWebImpl({
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: background.path,
      filterQuality: background.filterQuality,
      repeat: background.imageRepeat,
    );
  }
}
