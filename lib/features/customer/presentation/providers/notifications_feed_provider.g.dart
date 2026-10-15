// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationsFeedHash() => r'8657a028d7791ebe7ad068e64a799d81fdb0526b';

/// There is no notifications backend — every real notice goes to WhatsApp
/// (see `CLAUDE.md`). This reads the customer's own orders, newest first, as
/// a stand-in activity feed rather than inventing a parallel store.
///
/// Copied from [notificationsFeed].
@ProviderFor(notificationsFeed)
final notificationsFeedProvider =
    AutoDisposeFutureProvider<List<Order>>.internal(
      notificationsFeed,
      name: r'notificationsFeedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationsFeedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationsFeedRef = AutoDisposeFutureProviderRef<List<Order>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
