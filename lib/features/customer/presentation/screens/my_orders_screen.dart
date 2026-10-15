import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/order_list_tile.dart';
import '../providers/my_orders_controller.dart';
import 'order_detail_screen.dart';

/// My Orders tab body — two internal tabs (Ongoing / History) over the same
/// paginated-list controller, each keyed by its own `openOnly` family value.
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
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
          tabs: const [Tab(text: 'Ongoing'), Tab(text: 'History')],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _OrdersList(openOnly: true),
              _OrdersList(openOnly: false),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrdersList extends ConsumerStatefulWidget {
  const _OrdersList({required this.openOnly});

  final bool openOnly;

  @override
  ConsumerState<_OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends ConsumerState<_OrdersList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(myOrdersControllerProvider(widget.openOnly).notifier).loadMore();
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
    final state = ref.watch(myOrdersControllerProvider(widget.openOnly));

    if (state.loading && state.paginated.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.paginated.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: widget.openOnly ? 'No ongoing orders' : 'No orders yet',
        message: state.error?.message,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(myOrdersControllerProvider(widget.openOnly).notifier).refresh(),
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
              MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
            ),
          );
        },
      ),
    );
  }
}
