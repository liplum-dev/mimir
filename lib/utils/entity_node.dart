import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';

class EntityNodeEvent {
  final EntityNode source;

  /// the event was handled and consumed.
  var consumed = false;

  EntityNodeEvent({
    required this.source,
  });
}

class EntityNodeStateChangeEvent<State> extends EntityNodeEvent {
  final State oldState;
  final State newState;

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

abstract mixin class EntityNodeBase<State> implements EntityNode<State> {
  @override
  late final bool hasBuilt;

  late State _state;

  @override
  State get state => _state;

  @override
  set state(State state) {
    final old = _state;
    _state = state;
    onStateChange(old, state);
  }

  void onStateChange(State oldState, State newState) {
    travelEvent(EntityNodeStateChangeEvent(
      source: this,
      oldState: oldState,
      newState: newState,
    ));
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
      queue.addAll(child.children);
    }
  }

  @override
  FutureOr<void> bubbleEvent(EntityNodeEvent event) async {
    var cur = parent;
    while (cur != null) {
      await cur.onHandleEvent(event);
      cur = cur.parent;
    }
  }
}
