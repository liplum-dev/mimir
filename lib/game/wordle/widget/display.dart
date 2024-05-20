import 'dart:async';

import 'package:flutter/material.dart';
import '../widget/validation_provider.dart';
import 'input.dart';
import '../event_bus.dart';
import 'dart:math' as math;

class WordleDisplayWidget extends StatefulWidget {
  const WordleDisplayWidget({
    super.key,
    required this.wordLen,
    required this.maxChances,
  });

  final int wordLen;
  final int maxChances;

  @override
  State<WordleDisplayWidget> createState() => _WordleDisplayWidgetState();
}

class _WordleDisplayWidgetState extends State<WordleDisplayWidget> with TickerProviderStateMixin {
  late final StreamSubscription $attempt;
  late final StreamSubscription $newGame;
  int r = 0;
  int c = 0;
  bool onAnimation = false;
  bool acceptInput = true;
  late final List<List<Map<String, dynamic>>> inputs;

  void _validationAnimation(List<int> validation) async {
    onAnimation = true;
    bool result = true;
    for (int i = 0; i < widget.wordLen && onAnimation; i++) {
      setState(() {
        inputs[r][i]["State"] = validation[i];
      });
      if (validation[i] != 1) {
        result = false;
      }
      await Future.delayed(const Duration(milliseconds: 240));
    }
    if (!onAnimation) {
      return;
    }
    wordleEventBus.fire(const WordleAnimationStopEvent());
    onAnimation = false;
    r++;
    c = 0;
    if (r == widget.maxChances || result == true) {
      wordleEventBus.fire(const WordleAnimationStopEvent());
      acceptInput = false;
    }
  }

  void _onValidation(WordleAttemptEvent event) {
    List<int> validation = event.validation;
    _validationAnimation(validation);
  }

  void _onNewGame(WordleNewGameEvent event) {
    setState(() {
      r = 0;
      c = 0;
      onAnimation = false;
      acceptInput = true;
      for (int i = 0; i < widget.maxChances; i++) {
        for (int j = 0; j < widget.wordLen; j++) {
          inputs[i][j]["Letter"] = "";
          inputs[i][j]["State"] = 0;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    inputs = [
      for (int i = 0; i < widget.maxChances; i++)
        [
          for (int j = 0; j < widget.wordLen; j++)
            {
              "Letter": "",
              "State": 0,
              "InputAnimationController": AnimationController(
                  duration: const Duration(milliseconds: 50),
                  reverseDuration: const Duration(milliseconds: 100),
                  vsync: this),
            }
        ]
    ];
    $attempt = wordleEventBus.on<WordleAttemptEvent>().listen(_onValidation);
    $newGame = wordleEventBus.on<WordleNewGameEvent>().listen(_onNewGame);
  }

  @override
  void dispose() {
    $attempt.cancel();
    $newGame.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<InputNotification>(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
              child: Align(
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: widget.wordLen / widget.maxChances,
                  child: Column(
                    //Column(
                    children: [
                      for (int i = 0; i < widget.maxChances; i++)
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int j = 0; j < widget.wordLen; j++)
                                AnimatedBuilder(
                                    animation: inputs[i][j]["InputAnimationController"],
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: Tween<double>(begin: 1, end: 1.1)
                                            .evaluate(inputs[i][j]["InputAnimationController"]),
                                        child: child,
                                      );
                                    },
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 700),
                                            switchInCurve: Curves.easeOut,
                                            reverseDuration: const Duration(milliseconds: 0),
                                            transitionBuilder: (child, animation) {
                                              return AnimatedBuilder(
                                                  animation: animation,
                                                  child: child,
                                                  builder: (context, child) {
                                                    var _animation =
                                                        Tween<double>(begin: math.pi / 2, end: 0).animate(animation);
                                                    // return ConstrainedBox(
                                                    //   constraints: BoxConstraints.tightFor(height: constraints.maxHeight * _animation.value),
                                                    //   child: child,
                                                    // );
                                                    return Transform(
                                                      transform: Matrix4.rotationX(_animation.value),
                                                      alignment: Alignment.center,
                                                      child: child,
                                                    );
                                                  });
                                            },
                                            child: Padding(
                                              key: ValueKey(
                                                  (inputs[i][j]["State"] == 0 || inputs[i][j]["State"] == 3) ? 0 : 1),
                                              padding: const EdgeInsets.all(5.0),
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: inputs[i][j]["State"] == 1
                                                        ? Colors.green[600]!
                                                        : inputs[i][j]["State"] == 2
                                                            ? Colors.yellow[800]!
                                                            : inputs[i][j]["State"] == 3
                                                                ? Theme.of(context).brightness == Brightness.dark
                                                                    ? Colors.grey[400]!
                                                                    : Colors.grey[850]!
                                                                : inputs[i][j]["State"] == -1
                                                                    ? Colors.grey[700]!
                                                                    : Theme.of(context).brightness == Brightness.dark
                                                                        ? Colors.grey[700]!
                                                                        : Colors.grey[400]!,
                                                    width: 2.0,
                                                  ),
                                                  color: inputs[i][j]["State"] == 1
                                                      ? Colors.green[600]!
                                                      : inputs[i][j]["State"] == 2
                                                          ? Colors.yellow[800]!
                                                          : inputs[i][j]["State"] == -1
                                                              ? Colors.grey[700]!
                                                              : Theme.of(context).brightness == Brightness.dark
                                                                  ? Colors.grey[850]!
                                                                  : Colors.white,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    inputs[i][j]["Letter"],
                                                    style: TextStyle(
                                                      color: inputs[i][j]["State"] == 3
                                                          ? Theme.of(context).brightness == Brightness.dark
                                                              ? Colors.white
                                                              : Colors.grey[850]!
                                                          : Colors.white,
                                                      fontSize: 30,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 30.0),
            child: WordleKeyboard(),
          ),
        ],
      ),
      onNotification: (noti) {
        if (noti.type == InputType.singleCharacter) {
          if (r < widget.maxChances && c < widget.wordLen && !onAnimation && acceptInput) {
            setState(() {
              inputs[r][c]["Letter"] = noti.msg;
              inputs[r][c]["State"] = 3;
              var controller = inputs[r][c]["InputAnimationController"] as AnimationController;
              controller.forward().then((value) => controller.reverse());
              c++;
            });
          } else if (onAnimation) {
            return true;
          }
        } else if (noti.type == InputType.backSpace) {
          if (c > 0 && !onAnimation) {
            setState(() {
              inputs[r][c - 1]["Letter"] = "";
              inputs[r][c - 1]["State"] = 0;
              c--;
            });
          }
        }
        return false;
      },
    );
  }
}