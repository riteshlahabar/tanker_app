import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/order_list_tile.dart';
import '../providers/admin_orders_controller.dart';
import '../widgets/admin_order_filter_bar.dart';
import 'admin_order_detail_screen.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(adminOrdersControllerProvider.notifier).loadMore();
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
    final state = ref.watch(adminOrdersControllerProvider);

    return Column(
      children: [
        const AdminOrderFilterBar(),
        Expanded(
          child: state.loading && state.paginated.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.paginated.isEmpty
                  ? EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No orders match these filters',
                      message: state.error?.message,
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(adminOrdersControllerProvider.notifier).refresh(),
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
                              MaterialPageRoute(
                                builder: (_) => AdminOrderDetailScreen(orderId: order.id),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
