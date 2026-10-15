import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/delivery_slot.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/session_expiry_bus.dart';
import '../repositories/delivery_slot_repository.dart';
import '../repositories/delivery_slot_repository_impl.dart';
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

/// The windows the panel offers, for a form's dropdown.
@riverpod
Future<List<DeliverySlot>> deliverySlotOptions(Ref ref) async {
  final result = await ref.read(deliverySlotRepositoryProvider).active();

  return result.when(
    success: (slots) => slots,
    error: (failure) => throw failure,
  );
}
