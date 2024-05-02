import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

class EntityNodeEvent {
  final EntityNode source;

  /// the event was handled and consumed.
  var consumed = false;

  EntityNodeEvent({
    required this.source,
  });
}

class EntityNodeStateChangeEvent<TState> extends EntityNodeEvent {
  final TState? oldState;
  final TState newState;

  EntityNodeStateChangeEvent({
    required super.source,
    required this.oldState,
    required this.newState,
  });
}

abstract interface class EntityNode<State> {
  late State state;

  EntityNode? get parent;

  List<EntityNode> get children;

  bool get hasBuilt;

  void build();

  FutureOr<void> travelEvent(EntityNodeEvent event);

  FutureOr<void> bubbleEvent(EntityNodeEvent event);

  FutureOr<void> onHandleEvent(EntityNodeEvent event);

  static void buildTree(EntityNode root) {
    assert(root.isRoot);
    root.build();
    final queue = Queue<EntityNode>();
    queue.addAll(root.children);

    while (queue.isNotEmpty) {
      final child = queue.removeFirst();
      if (!child.hasBuilt) {
        child.build();
      }
      queue.addAll(child.children);
    }
  }
}

extension EntityNodeX on EntityNode {
  bool get isRoot => parent == null;

  bool get isLeaf => children.isEmpty;
}

abstract mixin class EntityNodeBase<TState> implements EntityNode<TState> {
  @override
  late bool hasBuilt = false;
  static const empty = Object();
  dynamic _state = empty;

  @override
  TState get state => _state == empty ? throw UnsupportedError("state has not been initialized.") : _state as TState;

  bool get stateInitialized => _state != empty;

  @override
  set state(TState state) {
    final old = stateInitialized ? _state as TState : null;
    _state = state;
    onStateChange(old, state);
  }

  @mustCallSuper
  void onStateChange(TState? oldState, TState newState) {
    travelEvent(EntityNodeStateChangeEvent(
      source: this,
      oldState: oldState,
      newState: newState,
    ));
  }

  @override
  FutureOr<void> onHandleEvent(EntityNodeEvent event) {
    if (kDebugMode) {
      print("$event on $runtimeType#$hashCode");
    }
  }

  @override
  @mustCallSuper
  void build() {
    hasBuilt = true;
  }

  @override
  FutureOr<void> travelEvent(EntityNodeEvent event) async {
    final queue = Queue<EntityNode>();
    queue.addAll(children);

    while (queue.isNotEmpty) {
      final child = queue.removeFirst();
      await child.onHandleEvent(event);
      if (event.consumed) {
        break;
      }
      queue.addAll(child.children);
    }
  }

  @override
  FutureOr<void> bubbleEvent(EntityNodeEvent event) async {
    var cur = parent;
    while (cur != null) {
      await cur.onHandleEvent(event);
      if (event.consumed) {
        break;
      }
      cur = cur.parent;
    }
  }
}
