import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
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
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;

    if (position.pixels > position.maxScrollExtent - 200) {
      ref.read(adminOrdersControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminOrdersControllerProvider);

    return Column(
      children: [
        const AdminOrderFilterBar(),
        if (!state.loading && !state.paginated.isEmpty) _CountLine(total: state.paginated.total),
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
                        padding: const EdgeInsets.only(top: 4, bottom: 16),
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
                            // The admin is looking across everybody, so the
                            // customer leads the row and the driver — or
                            // "Unassigned" — sits in the footer.
                            showParties: true,
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

/// How many orders the current filters actually match. Without it the list is
/// just "some orders" — the count is what tells the owner whether a filter did
/// what they expected.
class _CountLine extends StatelessWidget {
  const _CountLine({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 16, 2),
        child: Text(
          total == 1 ? '1 order' : '$total orders',
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: appTextColorSecondary,
          ),
        ),
      ),
    );
  }
}
