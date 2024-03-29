import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/design/adaptive/multiplatform.dart';

import 'entity/board.dart';
import 'save.dart';
import 'widget/empty_board.dart';
import 'widget/score_board.dart';
import 'widget/tile_board.dart';
import 'theme.dart';
import 'manager/board.dart';
import 'i18n.dart';

class Game2048 extends ConsumerStatefulWidget {
  final bool newGame;

  const Game2048({
    super.key,
    this.newGame = true,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameState();
}

class _GameState extends ConsumerState<Game2048> with TickerProviderStateMixin, WidgetsBindingObserver {
  //The controller used to move the the tiles
  late final AnimationController _moveController = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  )..addStatusListener((status) {
      //When the movement finishes merge the tiles and start the scale animation which gives the pop effect.
      if (status == AnimationStatus.completed) {
        ref.read(boardManager.notifier).merge();
        _scaleController.forward(from: 0.0);
      }
    });

  //The curve animation for the move animation controller.
  late final CurvedAnimation _moveAnimation = CurvedAnimation(
    parent: _moveController,
    curve: Curves.easeInOut,
  );

  //The controller used to show a popup effect when the tiles get merged
  late final AnimationController _scaleController = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  )..addStatusListener((status) {
      //When the scale animation finishes end the round and if there is a queued movement start the move controller again for the next direction.
      if (status == AnimationStatus.completed) {
        if (ref.read(boardManager.notifier).endRound()) {
          _moveController.forward(from: 0.0);
        }
      }
    });

  //The curve animation for the scale animation controller.
  late final CurvedAnimation _scaleAnimation = CurvedAnimation(
    parent: _scaleController,
    curve: Curves.easeInOut,
  );

  final $focus = FocusNode();

  @override
  void initState() {
    super.initState();
    //Add an Observer for the Lifecycles of the App
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero).then((value) {
      if (widget.newGame) {
        ref.read(boardManager.notifier).newGame();
      } else {
        final save = Save2048.storage.load();
        if (save != null) {
          ref.read(boardManager.notifier).fromSave(Board.fromSave(save));
        } else {
          ref.read(boardManager.notifier).newGame();
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //Save current state when the app becomes inactive
    if (state == AppLifecycleState.inactive) {
      ref.read(boardManager.notifier).save();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void deactivate() {
    super.deactivate();
    ref.read(boardManager.notifier).save();
  }

  @override
  void dispose() {
    //Remove the Observer for the Lifecycles of the App
    WidgetsBinding.instance.removeObserver(this);

    $focus.dispose();
    //Dispose the animations.
    _moveAnimation.dispose();
    _scaleAnimation.dispose();
    _moveController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: i18n.title.text(),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(boardManager.notifier).newGame();
            },
            icon: Icon(context.icons.refresh),
          )
        ],
      ),
      body: KeyboardListener(
        autofocus: true,
        focusNode: $focus,
        onKeyEvent: (event) {
          //Move the tile with the arrows on the keyboard on Desktop
          if (!_moveController.isCompleted) return;
          if (ref.read(boardManager.notifier).onKey(event)) {
            _moveController.forward(from: 0.0);
          }
        },
        child: SwipeDetector(
          onSwipe: (direction, offset) {
            if (ref.read(boardManager.notifier).move(direction)) {
              _moveController.forward(from: 0.0);
            }
          },
          child: Scaffold(
            backgroundColor: backgroundColor,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '2048',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 52.0),
                      ),
                      ScoreBoard(),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 32.0,
                ),
                Stack(
                  children: [
                    const EmptyBoardWidget(),
                    TileBoardWidget(moveAnimation: _moveAnimation, scaleAnimation: _scaleAnimation)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
