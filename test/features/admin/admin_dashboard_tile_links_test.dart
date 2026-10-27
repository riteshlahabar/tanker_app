import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/core/network/api_result.dart';
import 'package:tanker_app/core/router/shell_tabs_controller.dart';
import 'package:tanker_app/features/admin/domain/admin_dashboard.dart';
import 'package:tanker_app/features/admin/domain/admin_dashboard_repository.dart';
import 'package:tanker_app/features/admin/domain/admin_order_filter.dart';
import 'package:tanker_app/features/admin/domain/admin_order_repository.dart';
import 'package:tanker_app/features/admin/domain/admin_report_definition.dart';
import 'package:tanker_app/features/admin/domain/admin_report_filter.dart';
import 'package:tanker_app/features/admin/domain/admin_report_repository.dart';
import 'package:tanker_app/features/admin/domain/admin_report_result.dart';
import 'package:tanker_app/features/admin/presentation/providers/admin_providers.dart';
import 'package:tanker_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:tanker_app/features/admin/presentation/screens/customer_list_screen.dart';
import 'package:tanker_app/features/admin/presentation/screens/driver_list_screen.dart';
import 'package:tanker_app/features/admin/presentation/screens/report_detail_screen.dart';
import 'package:tanker_app/features/admin/presentation/screens/schedule_list_screen.dart';
import 'package:tanker_app/features/admin/presentation/screens/tanker_list_screen.dart';
import 'package:tanker_app/shared/models/nav_tab.dart';
import 'package:tanker_app/shared/models/order.dart';
import 'package:tanker_app/shared/models/order_status.dart';
import 'package:tanker_app/shared/models/paginated.dart';

/// A dashboard counter is a question — "six orders today, which six?" — so
/// every tile under Today and Coming up opens the list it was counted from,
/// already filtered. What is asserted here is the filter each one applies,
/// because a tile that lands on an unfiltered list is worse than one that
/// does nothing: it looks like it answered.
class _FakeDashboard implements AdminDashboardRepository {
  @override
  Future<ApiResult<AdminDashboard>> summary() async => Success(
        AdminDashboard.fromJson(const <String, dynamic>{
          'tankers': 4,
          'drivers': 3,
          'customers': 20,
          'scheduled_tomorrow': 2,
          'orders_today': 6,
          'pending': 1,
          'delivered_today': 5,
          'revenue_today': 12000,
          'tankers_delivered_today': 7,
          'open_orders': <Map<String, dynamic>>[],
          'open_total': 0,
        }),
      );
}

/// Records the filter the Orders list was actually asked for.
class _RecordingOrders implements AdminOrderRepository {
  final filters = <AdminOrderFilter>[];

  @override
  Future<ApiResult<Paginated<Order>>> list(AdminOrderFilter filter, {int page = 1}) async {
    filters.add(filter);

    return const Success(Paginated<Order>.empty());
  }

  @override
  Future<ApiResult<Order>> show(int orderId) => throw UnimplementedError();

  @override
  Future<ApiResult<Order>> create({
    required int customerId,
    required int driverId,
    required String deliveryAddress,
    required DateTime deliveryDate,
    int? spotId,
    double? tankerRate,
    int? deliverySlotId,
    int? tankerCount,
    String? notes,
  }) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<Order>> assign(int orderId, {required int driverId, int? spotId}) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<Order>> reassign(
    int orderId, {
    required int driverId,
    int? spotId,
    String? reason,
  }) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<Order>> cancel(int orderId, String reason) => throw UnimplementedError();
}

/// Serves the reports menu and records what each report was asked for.
class _RecordingReports implements AdminReportRepository {
  final shows = <({String key, AdminReportFilter filter})>[];

  @override
  Future<ApiResult<List<AdminReportDefinition>>> index() async => const Success([
        AdminReportDefinition(
          key: 'daily-delivery',
          title: 'Daily Delivery',
          filterFields: [],
        ),
      ]);

  @override
  Future<ApiResult<AdminReportResult>> show(String key, AdminReportFilter filter) async {
    shows.add((key: key, filter: filter));

    return const Success(AdminReportResult(
      key: 'daily-delivery',
      title: 'Daily Delivery',
      rangeLabel: 'Today',
      headings: ['Order'],
      rows: [],
      totals: {},
    ));
  }
}

void main() {
  late _RecordingOrders orders;
  late _RecordingReports reports;
  late ProviderContainer container;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(411, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    orders = _RecordingOrders();
    reports = _RecordingReports();
    container = ProviderContainer(
      overrides: [
        adminDashboardRepositoryProvider.overrideWithValue(_FakeDashboard()),
        adminOrderRepositoryProvider.overrideWithValue(orders),
        adminReportRepositoryProvider.overrideWithValue(reports),
      ],
    );
    addTearDown(container.dispose);

    // The tiles move the shell by tab *label*, so the shell has to have
    // registered its tabs for the jump to land anywhere.
    container.read(shellTabsProvider.notifier).register(const [
      NavTab(label: 'Dashboard', icon: Icons.dashboard, title: 'Dashboard', body: SizedBox()),
      NavTab(label: 'Orders', icon: Icons.receipt, title: 'Orders', body: SizedBox()),
    ]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: AdminDashboardScreen())),
      ),
    );

    await tester.pumpAndSettle();
  }

  /// The filter the Orders list was last asked for. The list loads once on its
  /// own, so the tap is the *last* entry, not the only one.
  AdminOrderFilter lastFilter() => orders.filters.last;

  bool isToday(DateTime? date) {
    final now = DateTime.now();

    return date != null && date.year == now.year && date.month == now.month && date.day == now.day;
  }

  testWidgets('Orders today opens the Orders tab filtered to today', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Orders today'));
    await tester.pumpAndSettle();

    expect(isToday(lastFilter().from), isTrue);
    expect(isToday(lastFilter().to), isTrue);
    // Today's orders are every status, not the open ones.
    expect(lastFilter().status, isNull);

    final tabs = container.read(shellTabsProvider);
    expect(tabs.tabs[tabs.index].label, 'Orders');
  });

  testWidgets('Pending opens the whole waiting queue, not just today', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Pending'));
    await tester.pumpAndSettle();

    expect(lastFilter().status, OrderStatus.pending);
    // The decisive one: an order placed yesterday and still pending is what
    // the owner is tapping to find, so a date here would hide it.
    expect(lastFilter().from, isNull);
  });

  // One test each rather than a loop in one: re-pumping a second tree inside
  // a single test leaves Riverpod's dispose timer pending and the run fails
  // on that instead of on the assertion.
  for (final label in ['Delivered today', 'Tankers delivered']) {
    testWidgets('$label opens today\'s deliveries', (tester) async {
      await pump(tester);

      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(lastFilter().status, OrderStatus.delivered);
      expect(isToday(lastFilter().from), isTrue);
    });
  }

  testWidgets('Revenue today opens the Daily Delivery report, dated today', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Revenue today'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(ReportDetailScreen), findsOneWidget);

    // One fetch, already carrying today — not the server's default month
    // followed by a second request. `applyInitial` seeds the filter before
    // the controller's deferred first load runs.
    expect(reports.shows, hasLength(1));
    expect(reports.shows.single.key, 'daily-delivery');
    expect(isToday(reports.shows.single.filter.from), isTrue);
    expect(isToday(reports.shows.single.filter.to), isTrue);
  });

  testWidgets('Coming up tiles push their own master-data screens', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Scheduled tomorrow'));
    // Not pumpAndSettle: the pushed list spins on a repository this test does
    // not stub, and a spinner never settles. One frame plus the route
    // transition is all the claim needs — that the right screen was pushed.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Not the Orders list: tomorrow's orders are written overnight by the
    // generator and do not exist yet.
    expect(find.byType(ScheduleListScreen), findsOneWidget);
  });

  // The three "Active" tiles count `status = true`, so each opens its list
  // already narrowed to active — otherwise the list would include retired
  // vehicles and deactivated people and could never add up to the figure.
  testWidgets('Active tankers opens the Tankers list, active only', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Active tankers'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(tester.widget<TankerListScreen>(find.byType(TankerListScreen)).initialStatus, isTrue);
  });

  testWidgets('Active drivers opens the Drivers list, active only', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Active drivers'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(tester.widget<DriverListScreen>(find.byType(DriverListScreen)).initialStatus, isTrue);
  });

  testWidgets('Active customers opens the Customers list, active only', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Active customers'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      tester.widget<CustomerListScreen>(find.byType(CustomerListScreen)).initialStatus,
      isTrue,
    );
  });

  testWidgets('the drawer still lists everyone — no status is forced there', (tester) async {
    // The family argument is what keeps the two entry points apart: the
    // dashboard's list and the drawer's are different provider instances, and
    // only the dashboard's carries a filter.
    const fromDrawer = DriverListScreen();

    expect(fromDrawer.initialStatus, isNull);
  });
}
