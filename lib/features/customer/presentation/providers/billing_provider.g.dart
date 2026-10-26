// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customerBillingHash() => r'6b1f0c2d4a9e7538c0d1b4e82f6a35d7c9481ae0';

/// Every order the customer has, folded into months and days.
///
/// Copied from [customerBilling].
@ProviderFor(customerBilling)
final customerBillingProvider =
    AutoDisposeFutureProvider<BillingSummary>.internal(
      customerBilling,
      name: r'customerBillingProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$customerBillingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CustomerBillingRef = AutoDisposeFutureProviderRef<BillingSummary>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
