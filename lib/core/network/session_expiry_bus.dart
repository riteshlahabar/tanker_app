import 'dart:async';

/// Announces that the session could not be rescued — the refresh token was
/// rejected, so the user must sign in again.
///
/// This exists to break a dependency cycle. The Dio interceptor has to report
/// an unrecoverable 401, but the thing that reacts to it (the session
/// controller) is built on top of Dio. Both sides depend on this bus instead
/// of on each other.
class SessionExpiryBus {
  SessionExpiryBus() : _controller = StreamController<void>.broadcast();

  final StreamController<void> _controller;

  Stream<void> get stream => _controller.stream;

  void expired() {
    if (!_controller.isClosed) _controller.add(null);
  }

  void dispose() => _controller.close();
}
