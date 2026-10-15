import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/auth_repository.dart';

part 'auth_providers.g.dart';

/// The repository is exposed as its interface, so every screen and controller
/// depends on [AuthRepository] and a test can override this with a fake.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
      client: ref.watch(apiClientProvider),
      storage: ref.watch(secureStorageProvider),
    );
