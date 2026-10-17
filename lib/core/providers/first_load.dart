import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Starts a notifier's first fetch *after* `build()` has returned.
///
/// Kicking the fetch off from inside `build()` looks harmless but is not: a
/// load whose first statement reads `state` — `state = state.copyWith(...)`
/// — hits a provider that has no state yet and throws
/// `Bad state: Tried to read the state of an uninitialized provider`.
/// Because the call is unawaited, that throw is swallowed: the fetch never
/// runs, the state keeps its `loading: true` default, and the screen spins
/// for ever with nothing in the logs.
///
/// A microtask defers the load until the provider is mounted, so the first
/// statement sees a real state. The disposal guard covers an autoDispose
/// provider that is thrown away before the microtask gets its turn —
/// touching `state` after that point throws just as readily.
class FirstLoad {
  FirstLoad._();

  static void after(Ref ref, Future<void> Function() load) {
    var alive = true;

    ref.onDispose(() => alive = false);

    Future<void>.microtask(() => alive ? load() : null);
  }
}
