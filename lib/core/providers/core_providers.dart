import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/session_controller.dart';
import '../../features/auth/presentation/providers/session_state.dart';
import '../../shared/models/delivery_slot.dart';
import '../../shared/models/user_role.dart';
import '../alerts/buzzer.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/session_expiry_bus.dart';
import '../repositories/customer_lookup_repository.dart';
import '../repositories/delivery_slot_repository.dart';
import '../repositories/delivery_slot_repository_impl.dart';
import '../repositories/order_alerts_repository.dart';
import '../repositories/order_alerts_repository_impl.dart';
import '../storage/prefs.dart';
import '../storage/secure_storage.dart';

part 'core_providers.g.dart';

/// Shared preferences needs an async load, so `main()` does it once and
/// overrides this provider with the result. Reading it before that override is
/// a wiring mistake, which is why it throws rather than returning a default.
@Riverpod(keepAlive: true)
Prefs prefs(Ref ref) => throw UnimplementedError(
      'prefsProvider must be overridden in main() with the loaded SharedPreferences.',
    );

@Riverpod(keepAlive: true)
SecureStorage secureStorage(Ref ref) => const SecureStorage(
      FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      ),
    );

@Riverpod(keepAlive: true)
SessionExpiryBus sessionExpiryBus(Ref ref) {
  final bus = SessionExpiryBus();

  ref.onDispose(bus.dispose);

  return bus;
}

/// The configured HTTP client. One instance for the whole app, so the token
/// refresh in [AuthInterceptor] is shared rather than repeated per screen.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final storage = ref.watch(secureStorageProvider);
  final bus = ref.watch(sessionExpiryBusProvider);

  final client = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: const {'Accept': 'application/json'},
      // Dio's default validateStatus is kept deliberately: a 4xx has to raise
      // a DioException, or AuthInterceptor.onError never sees the 401 it
      // refreshes on and ErrorMapper never reads the real status code.
    ),
  );

  client.interceptors.add(
    AuthInterceptor(
      storage: storage,
      refreshClient: AuthInterceptor.bareClient(),
      onSessionLost: () async {
        await storage.clear();
        bus.expired();
      },
    ),
  );

  return client;
}

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) => ApiClient(ref.watch(dioProvider));

/// Shared by every role that needs the panel's delivery windows (the
/// customer's order form, the admin's New Order).
@Riverpod(keepAlive: true)
DeliverySlotRepository deliverySlotRepository(Ref ref) =>
    DeliverySlotRepositoryImpl(client: ref.watch(apiClientProvider));

/// Customer search for whichever role is writing an order.
///
/// The endpoint is chosen **here, once**, from the signed-in role: an admin
/// talks to `/admin/customers`, a driver to `/driver/customers`. A screen that
/// picked its own path would 403 the moment the shared picker was reused by
/// the other role, and the failure would read as a broken picker rather than a
/// wrong URL. Anyone else — a customer, or a session still being restored —
/// gets the driver path, which their token simply cannot use; no role but
/// those two has a customer picker to show.
@Riverpod(keepAlive: true)
CustomerLookupRepository customerLookupRepository(Ref ref) {
  final session = ref.watch(sessionControllerProvider);
  final isAdmin = session is SessionSignedIn && session.user.role == UserRole.admin;

  return CustomerLookupRepositoryImpl(
    client: ref.watch(apiClientProvider),
    path: isAdmin ? '/admin/customers' : '/driver/customers',
  );
}

/// The buzzer's alert list, for whichever of the two rung roles is signed in.
///
/// The path prefix is chosen **here, once**, exactly as
/// [customerLookupRepository] does it: the endpoints are the same two shapes
/// under `/admin` and `/driver`, and the audience comes from the token, so a
/// screen that picked its own path would only ever be picking a 403. Anyone
/// else — a customer, or a session still being restored — gets the driver
/// path they cannot call, and [OrderAlertsController] never polls for them.
@Riverpod(keepAlive: true)
OrderAlertsRepository orderAlertsRepository(Ref ref) {
  final session = ref.watch(sessionControllerProvider);
  final isAdmin = session is SessionSignedIn && session.user.role == UserRole.admin;

  return OrderAlertsRepositoryImpl(
    client: ref.watch(apiClientProvider),
    path: isAdmin ? '/admin' : '/driver',
  );
}

/// The noise itself. One instance for the app — two players would mean two
/// overlapping loops — and overridden with a [SilentBuzzer] in tests, which
/// is the whole reason [Buzzer] is an interface.
@Riverpod(keepAlive: true)
Buzzer buzzer(Ref ref) {
  final buzzer = LoopingBuzzer();

  ref.onDispose(buzzer.dispose);

  return buzzer;
}

/// The windows the panel offers, for a form's dropdown.
@riverpod
Future<List<DeliverySlot>> deliverySlotOptions(Ref ref) async {
  final result = await ref.read(deliverySlotRepositoryProvider).active();

  return result.when(
    success: (slots) => slots,
    error: (failure) => throw failure,
  );
}
