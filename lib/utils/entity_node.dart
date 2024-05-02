import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

bool _acceptAll(EntityNode node) => true;

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

  int get depth;

  EntityNode? get parent;

  List<EntityNode> get children;

  bool containsChild(EntityNode node);

  bool get hasBuilt;

  void build();

  FutureOr<void> travelEvent(
    EntityNodeEvent event, {
    int depth = -1,
    bool Function(EntityNode node) filter = _acceptAll,
  });

  FutureOr<void> bubbleEvent(
    EntityNodeEvent event, {
    int depth = -1,
    bool Function(EntityNode node) filter = _acceptAll,
  });

  FutureOr<void> onBubbleEvent(EntityNodeEvent event);

  FutureOr<void> onTravelEvent(EntityNodeEvent event);

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
  bool containsChild(EntityNode node) {
        return children.contains(node);
  }

  @override
  int get depth {
    int d = 0;
    var cur = parent;
    while (cur != null) {
      d++;
      cur = cur.parent;
    }
    return d;
  }

  @override
  TState get state => _state == empty ? throw UnsupportedError("state has not been initialized.") : _state as TState;

  bool get stateInitialized => _state != empty;

  @override
  set state(TState state) {
    final old = stateInitialized ? _state as TState : null;
    _state = state;
    onStateChange(old, state);
  }

  void onStateChange(TState? oldState, TState newState) {
    travelEvent(EntityNodeStateChangeEvent(
      source: this,
      oldState: oldState,
      newState: newState,
    ));
  }

  @override
  FutureOr<void> onBubbleEvent(EntityNodeEvent event) {
    if (kDebugMode) {
      print("$event on $runtimeType#$hashCode");
    }
  }

  @override
  FutureOr<void> onTravelEvent(EntityNodeEvent event) {
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
  FutureOr<void> travelEvent(
    EntityNodeEvent event, {
    int depth = -1,
    bool Function(EntityNode node) filter = _acceptAll,
  }) async {
    final queue = Queue<EntityNode>();
    queue.addAll(children);

    while (queue.isNotEmpty) {
      final child = queue.removeFirst();
      if (filter(child)) {
        await child.onBubbleEvent(event);
        if (event.consumed) {
          break;
        }
        if (depth < 0 || child.depth <= depth) {
          queue.addAll(child.children);
        }
      }
    }
  }

  @override
  FutureOr<void> bubbleEvent(
    EntityNodeEvent event, {
    int depth = -1,
    bool Function(EntityNode node) filter = _acceptAll,
  }) async {
    var cur = parent;
    int height = 0;
    while (cur != null) {
      await cur.onBubbleEvent(event);
      if (filter(cur)) {
        if (event.consumed) {
          break;
        }
        if (depth < 0 || height <= depth) {
          cur = cur.parent;
          height++;
        } else {
          break;
        }
      }
    }
  }
}
