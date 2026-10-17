import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/driver_order_repository_impl.dart';
import '../../data/driver_repository_impl.dart';
import '../../data/expense_repository_impl.dart';
import '../../data/spot_repository_impl.dart';
import '../../domain/driver_order_repository.dart';
import '../../domain/driver_repository.dart';
import '../../domain/expense_repository.dart';
import '../../domain/spot_repository.dart';

part 'driver_providers.g.dart';

@Riverpod(keepAlive: true)
DriverRepository driverRepository(Ref ref) => DriverRepositoryImpl(client: ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
DriverOrderRepository driverOrderRepository(Ref ref) =>
    DriverOrderRepositoryImpl(client: ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
SpotRepository spotRepository(Ref ref) => SpotRepositoryImpl(client: ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
ExpenseRepository expenseRepository(Ref ref) =>
    ExpenseRepositoryImpl(client: ref.watch(apiClientProvider));
