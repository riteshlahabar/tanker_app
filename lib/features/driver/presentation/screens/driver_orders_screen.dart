import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/order_list_tile.dart';
import '../providers/driver_orders_controller.dart';
import 'driver_order_detail_screen.dart';

/// Orders tab body — Active (`openOnly: true`) / Delivered (`openOnly: false`)
/// tabs, mirroring the customer's My Orders screen.
class DriverOrdersScreen extends StatefulWidget {
  const DriverOrdersScreen({super.key});

  @override
  State<DriverOrdersScreen> createState() => _DriverOrdersScreenState();
}

class _DriverOrdersScreenState extends State<DriverOrdersScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Active'), Tab(text: 'Delivered')],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _DriverOrdersList(openOnly: true),
              _DriverOrdersList(openOnly: false),
            ],
          ),
        ),
      ],
    );
  }
}

class _DriverOrdersList extends ConsumerStatefulWidget {
  const _DriverOrdersList({required this.openOnly});

  final bool openOnly;

  @override
  ConsumerState<_DriverOrdersList> createState() => _DriverOrdersListState();
}

class _DriverOrdersListState extends ConsumerState<_DriverOrdersList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(driverOrdersControllerProvider(widget.openOnly).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverOrdersControllerProvider(widget.openOnly));

    if (state.loading && state.paginated.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.paginated.isEmpty) {
      return EmptyState(
        icon: Icons.local_shipping_outlined,
        title: widget.openOnly ? 'No active deliveries' : 'No deliveries yet',
        message: state.error?.message,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(driverOrdersControllerProvider(widget.openOnly).notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.paginated.items.length + (state.loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.paginated.items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final order = state.paginated.items[index];

          return OrderListTile(
            order: order,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => DriverOrderDetailScreen(orderId: order.id)),
            ),
          );
        },
      ),
    );
  }
}
