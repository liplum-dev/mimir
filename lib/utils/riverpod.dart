import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension BuildContextRiverpodX on BuildContext {
  ProviderContainer riverpod({
    bool listen = true,
  }) =>
      ProviderScope.containerOf(
        this,
        listen: listen,
      );
}

class ListenableStateNotifier<T> extends StateNotifier<T> {
  final Listenable listenable;
  final T Function() get;

  ListenableStateNotifier(super._state, this.listenable, this.get) {
    listenable.addListener(_refresh);
  }

  void _refresh() {
    print("before ${state}");
    state = get();
    print("after ${state}");
  }

  @override
  void dispose() {
    listenable.removeListener(_refresh);
    super.dispose();
  }
}

extension ListenableRiverpodX on Listenable {
  AutoDisposeStateNotifierProvider<ListenableStateNotifier<T>, T> provider<T>({
    required T Function() get,
  }) {
    return StateNotifierProvider.autoDispose<ListenableStateNotifier<T>, T>((ref) {
      return ListenableStateNotifier(
        get(),
        this,
        get,
      );
    });
  }
}
