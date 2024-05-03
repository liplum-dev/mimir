import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AnimatedMarquee extends StatefulWidget {
  final List<Widget> children;
  final Duration transitionDuration;
  final Duration marqueeDuration;

  const AnimatedMarquee({
    super.key,
    required this.children,
    this.transitionDuration = Duration.zero,
    required this.marqueeDuration,
  });

  @override
  State<AnimatedMarquee> createState() => _AnimatedMarqueeState();
}

class _AnimatedMarqueeState extends State<AnimatedMarquee> {
  var curIndex = 0;
  late Timer marqueeTimer;

  @override
  void initState() {
    super.initState();
    marqueeTimer = startTimer(widget.marqueeDuration);
  }

  Timer startTimer(Duration duration) {
    return Timer.periodic(duration, (timer) {
      if (widget.children.isEmpty) {
        setIndex(0);
      } else {
        setState(() {
          setIndex((curIndex + 1) % widget.children.length);
        });
      }
    });
  }

  void setIndex(int newIndex) {
    if (newIndex != curIndex) {
      setState(() {
        curIndex = newIndex;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    marqueeTimer.cancel();
  }

  @override
  void didUpdateWidget(covariant AnimatedMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.marqueeDuration != widget.marqueeDuration) {
      marqueeTimer.cancel();
      marqueeTimer = startTimer(widget.marqueeDuration);
    }
    setState(() {
      setIndex(curIndex % widget.children.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.transitionDuration,
      child: widget.children[curIndex],
    );
  }
}

class AnimatedDualSwitcherController {
  _AnimatedDualSwitcherState? _attached;

  void switchTo(bool state) {
    final attached = _attached!;
    attached.$state = state;
    final alwaysSwitchTo = attached.widget.alwaysSwitchTo;
    if (alwaysSwitchTo == null) return;
    if (attached.$state != alwaysSwitchTo) {
      attached.passed = Duration.zero;
    }
    attached.passed = Duration.zero;
  }

  void _attach(_AnimatedDualSwitcherState state) {
    if (_attached != null) {
      throw FlutterError("$AnimatedDualSwitcherController should be attached only one at the same time.");
    }
    _attached = state;
  }

  void dispose() {
    _attached = null;
  }
}

class AnimatedDualSwitcher extends StatefulWidget {
  final Duration transitionDuration;
  final Duration switchDuration;
  final Widget trueChild;
  final Widget falseChild;
  final AnimatedDualSwitcherController? controller;
  final bool? alwaysSwitchTo;
  final bool initial;

  const AnimatedDualSwitcher({
    super.key,
    required this.transitionDuration,
    required this.switchDuration,
    required this.trueChild,
    required this.falseChild,
    this.controller,
    this.alwaysSwitchTo,
    required this.initial,
  });

  Widget _getWidget(bool state) {
    return state ? trueChild : falseChild;
  }

  @override
  State<AnimatedDualSwitcher> createState() => _AnimatedDualSwitcherState();
}

class _AnimatedDualSwitcherState extends State<AnimatedDualSwitcher> with SingleTickerProviderStateMixin {
  late Ticker marqueeTicker;
  var lastElapsed = Duration.zero;
  var passed = Duration.zero;
  late var _state = widget.initial;

  bool get $state => _state;

  set $state(bool newV) {
    if (newV != _state) {
      setState(() {
        _state = newV;
      });
    }
  }

  late var controller = widget.controller ?? AnimatedDualSwitcherController();

  @override
  void initState() {
    super.initState();
    startTicker();
    controller._attach(this);
  }

  @override
  void dispose() {
    marqueeTicker.dispose();
    super.dispose();
  }

  void startTicker() {
    marqueeTicker = createTicker((elapsed) {
      final alwaysSwitchTo = widget.alwaysSwitchTo;
      final delta = elapsed - lastElapsed;
      lastElapsed = elapsed;
      assert(elapsed >= lastElapsed);
      if ($state != alwaysSwitchTo) {
        passed += delta;
      }
      if (passed >= widget.switchDuration) {
        passed = Duration.zero;
        if (alwaysSwitchTo == null) {
          $state = !$state;
        } else {
          $state = alwaysSwitchTo;
        }
      }
    });
    marqueeTicker.start();
  }

  @override
  void didUpdateWidget(covariant AnimatedDualSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != controller) {
      controller.dispose();
      controller = (widget.controller ?? AnimatedDualSwitcherController()).._attach(this);
    }
    if (oldWidget.switchDuration != widget.switchDuration) {
      passed = Duration.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.transitionDuration,
      child: widget._getWidget($state),
    );
  }
}
