import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/alerts/buzzer.dart';
import 'package:tanker_app/core/errors/failure.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/core/providers/core_providers.dart';
import 'package:tanker_app/core/providers/opened_order.dart';
import 'package:tanker_app/core/providers/order_alerts_controller.dart';
import 'package:tanker_app/core/repositories/order_alerts_repository.dart';
import 'package:tanker_app/features/auth/domain/auth_user.dart';
import 'package:tanker_app/features/auth/presentation/providers/session_controller.dart';
import 'package:tanker_app/features/auth/presentation/providers/session_state.dart';
import 'package:tanker_app/shared/models/order.dart';
import 'package:tanker_app/shared/models/user_role.dart';

import '../support/order_fixture.dart';

/// Signs the container in without touching secure storage or the panel.
class _SignedInSession extends SessionController {
  _SignedInSession(this.role);

  final UserRole role;

  @override
  SessionState build() => SessionSignedIn(
        AuthUser(
          id: 7,
          firstName: 'Test',
          lastName: 'Person',
          fullName: 'Test Person',
          role: role,
          status: true,
          canSelfOrder: true,
        ),
      );
}

class _FakeAlerts implements OrderAlertsRepository {
  _FakeAlerts(this.answer);

  /// What the panel says is unseen. Replaced between polls by a test that
  /// wants the list to change.
  List<Order> answer;

  /// Set to refuse the next poll, as a timeout or a dead connection would.
  Failure? refuseWith;

  final List<int> markedSeen = [];
  int polls = 0;

  @override
  Future<ApiResult<List<Order>>> pending() async {
    polls++;

    final failure = refuseWith;

    if (failure != null) return Error(failure);

    return Success(answer);
  }

  @override
  Future<ApiResult<String>> markSeen(int orderId) async {
    markedSeen.add(orderId);
    answer = answer.where((order) => order.id != orderId).toList(growable: false);

    return const Success('');
  }
}

class _RecordingBuzzer implements Buzzer {
  int starts = 0;
  int stops = 0;
  bool sounding = false;

  @override
  Future<void> start() async {
    starts++;
    sounding = true;
  }

  @override
  Future<void> stop() async {
    stops++;
    sounding = false;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  ({ProviderContainer container, _FakeAlerts repository, _RecordingBuzzer buzzer}) harness({
    UserRole role = UserRole.driver,
    List<Order> waiting = const [],
  }) {
    final repository = _FakeAlerts(waiting.toList());
    final buzzer = _RecordingBuzzer();

    final container = ProviderContainer(
      overrides: [
        sessionControllerProvider.overrideWith(() => _SignedInSession(role)),
        orderAlertsRepositoryProvider.overrideWithValue(repository),
        buzzerProvider.overrideWithValue(buzzer),
      ],
    );

    addTearDown(container.dispose);

    // keepAlive, so something has to ask for it before it exists.
    container.listen(orderAlertsControllerProvider, (_, _) {});

    return (container: container, repository: repository, buzzer: buzzer);
  }

  /// Lets the build microtask and the first poll complete.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('an unseen order rings as soon as the first poll answers', () async {
    final h = harness(waiting: [fixtureOrder(id: 11)]);

    await settle();

    final state = h.container.read(orderAlertsControllerProvider);

    expect(state.watching, isTrue);
    expect(state.alerts.single.id, 11);
    expect(state.ringing, isTrue);
    expect(h.buzzer.sounding, isTrue);
  });

  test('a customer is never rung, so nothing is polled for them', () async {
    final h = harness(role: UserRole.customer, waiting: [fixtureOrder(id: 11)]);

    await settle();

    expect(h.container.read(orderAlertsControllerProvider).watching, isFalse);
    expect(h.repository.polls, 0);
    expect(h.buzzer.starts, 0);
  });

  test('marking it seen stops the noise and tells the panel', () async {
    final h = harness(waiting: [fixtureOrder(id: 11)]);

    await settle();
    expect(h.buzzer.sounding, isTrue);

    await h.container.read(orderAlertsControllerProvider.notifier).markSeen(11);

    expect(h.repository.markedSeen, [11]);
    expect(h.container.read(orderAlertsControllerProvider).alerts, isEmpty);
    expect(h.container.read(orderAlertsControllerProvider).ringing, isFalse);
    expect(h.buzzer.sounding, isFalse);
  });

  test('opening the order silences it, whichever list it was opened from', () async {
    final h = harness(waiting: [fixtureOrder(id: 11)]);

    await settle();

    // What an order detail controller announces when its screen opens.
    h.container.read(openedOrderProvider.notifier).opened(11);

    await settle();

    expect(h.repository.markedSeen, [11]);
    expect(h.buzzer.sounding, isFalse);
  });

  test('opening an order that is not ringing costs nothing', () async {
    final h = harness(waiting: [fixtureOrder(id: 11)]);

    await settle();

    h.container.read(openedOrderProvider.notifier).opened(99);

    await settle();

    expect(h.repository.markedSeen, isEmpty);
    // Still ringing: order 11 has not been looked at.
    expect(h.buzzer.sounding, isTrue);
  });

  test('Stop acknowledges everything waiting, so none of it comes back', () async {
    final h = harness(waiting: [fixtureOrder(id: 11), fixtureOrder(id: 12)]);

    await settle();
    expect(h.container.read(orderAlertsControllerProvider).alerts.length, 2);

    await h.container.read(orderAlertsControllerProvider.notifier).stopAll();

    expect(h.repository.markedSeen, [11, 12]);
    expect(h.container.read(orderAlertsControllerProvider).alerts, isEmpty);
    expect(h.buzzer.sounding, isFalse);
  });

  test('a failed poll keeps ringing — no connection is not "nothing waiting"', () async {
    final h = harness(waiting: [fixtureOrder(id: 11)]);

    await settle();
    expect(h.buzzer.sounding, isTrue);

    h.repository.refuseWith = const NetworkFailure('No connection.');

    await h.container.read(orderAlertsControllerProvider.notifier).refresh();

    expect(h.container.read(orderAlertsControllerProvider).alerts.single.id, 11);
    expect(h.container.read(orderAlertsControllerProvider).ringing, isTrue);
  });

  test('an order the panel drops — cancelled, or handed to another driver — goes quiet', () async {
    final h = harness(waiting: [fixtureOrder(id: 11)]);

    await settle();
    expect(h.buzzer.sounding, isTrue);

    // Exactly what `scopeAlerting` does on the panel: the row simply stops
    // matching, with no second write and no "clear the flag" call to forget.
    h.repository.answer = const [];

    await h.container.read(orderAlertsControllerProvider.notifier).refresh();

    expect(h.container.read(orderAlertsControllerProvider).alerts, isEmpty);
    expect(h.buzzer.sounding, isFalse);
    expect(h.repository.markedSeen, isEmpty);
  });
}
