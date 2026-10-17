import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/admin_customer_repository_impl.dart';
import '../../data/admin_dashboard_repository_impl.dart';
import '../../data/admin_delivery_slot_repository_impl.dart';
import '../../data/admin_driver_repository_impl.dart';
import '../../data/admin_expense_repository_impl.dart';
import '../../data/admin_order_repository_impl.dart';
import '../../data/admin_picker_repository_impl.dart';
import '../../data/admin_report_repository_impl.dart';
import '../../data/admin_schedule_repository_impl.dart';
import '../../data/admin_settings_repository_impl.dart';
import '../../data/admin_spot_repository_impl.dart';
import '../../data/admin_tanker_repository_impl.dart';
import '../../domain/admin_customer_repository.dart';
import '../../domain/admin_dashboard_repository.dart';
import '../../domain/admin_delivery_slot_repository.dart';
import '../../domain/admin_driver_repository.dart';
import '../../domain/admin_expense_repository.dart';
import '../../domain/admin_order_repository.dart';
import '../../domain/admin_picker_repository.dart';
import '../../domain/admin_report_repository.dart';
import '../../domain/admin_schedule_repository.dart';
import '../../domain/admin_settings_repository.dart';
import '../../domain/admin_spot_repository.dart';
import '../../domain/admin_tanker_repository.dart';

part 'admin_providers.g.dart';

@Riverpod(keepAlive: true)
AdminDashboardRepository adminDashboardRepository(Ref ref) =>
    AdminDashboardRepositoryImpl(client: ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
AdminOrderRepository adminOrderRepository(Ref ref) =>
    AdminOrderRepositoryImpl(client: ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
AdminPickerRepository adminPickerRepository(Ref ref) =>
    AdminPickerRepositoryImpl(client: ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
AdminSettingsRepository adminSettingsRepository(Ref ref) =>
    AdminSettingsRepositoryImpl(client: ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
AdminTankerRepository adminTankerRepository(Ref ref) =>
    AdminTankerRepositoryImpl(client: ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
AdminDriverRepository adminDriverRepository(Ref ref) =>
    AdminDriverRepositoryImpl(client: ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
AdminCustomerRepository adminCustomerRepository(Ref ref) =>
    AdminCustomerRepositoryImpl(client: ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
AdminSpotRepository adminSpotRepository(Ref ref) =>
    AdminSpotRepositoryImpl(client: ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
AdminDeliverySlotRepository adminDeliverySlotRepository(Ref ref) =>
    AdminDeliverySlotRepositoryImpl(client: ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
AdminScheduleRepository adminScheduleRepository(Ref ref) =>
    AdminScheduleRepositoryImpl(client: ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
AdminReportRepository adminReportRepository(Ref ref) =>
    AdminReportRepositoryImpl(client: ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
AdminExpenseRepository adminExpenseRepository(Ref ref) =>
    AdminExpenseRepositoryImpl(client: ref.watch(apiClientProvider));
