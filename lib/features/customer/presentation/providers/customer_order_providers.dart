import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/customer_order_repository_impl.dart';
import '../../domain/customer_order_repository.dart';

part 'customer_order_providers.g.dart';

@Riverpod(keepAlive: true)
CustomerOrderRepository customerOrderRepository(Ref ref) =>
    CustomerOrderRepositoryImpl(client: ref.watch(apiClientProvider));
