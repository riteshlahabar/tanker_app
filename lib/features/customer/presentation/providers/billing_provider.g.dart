// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customerBillingHash() => r'ef8491fbe373d7bae36c967b19d438c42efa1fae';

/// Every order the customer has, folded into months and days.
///
/// Built here rather than asked of the server because there is no billing
/// endpoint — and there does not need to be one: the orders already carry the
/// whole price rule (`tanker_rate × tanker_count = order_amount`), so the
/// arithmetic the customer wants to check is the arithmetic already on the
/// wire.
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
