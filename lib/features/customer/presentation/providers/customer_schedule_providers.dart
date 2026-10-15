import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/customer_schedule_repository_impl.dart';
import '../../domain/customer_schedule_repository.dart';

part 'customer_schedule_providers.g.dart';

@Riverpod(keepAlive: true)
CustomerScheduleRepository customerScheduleRepository(Ref ref) =>
    CustomerScheduleRepositoryImpl(client: ref.watch(apiClientProvider));
