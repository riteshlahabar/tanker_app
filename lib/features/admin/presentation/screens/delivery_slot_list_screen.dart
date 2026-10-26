import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/list_count_line.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../domain/admin_delivery_slot.dart';
import '../providers/admin_delivery_slots_controller.dart';
import '../widgets/delivery_slot_list_tile.dart';
import '../widgets/entity_filter_bar.dart';
import 'delivery_slot_form_screen.dart';

class DeliverySlotListScreen extends ConsumerStatefulWidget {
  const DeliverySlotListScreen({super.key});

  @override
  ConsumerState<DeliverySlotListScreen> createState() => _DeliverySlotListScreenState();
}

class _DeliverySlotListScreenState extends ConsumerState<DeliverySlotListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(adminDeliverySlotsControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openForm({AdminDeliverySlot? existing}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DeliverySlotFormScreen(existing: existing)),
    );

    await ref.read(adminDeliverySlotsControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminDeliverySlotsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Slots')),
      body: Column(
        children: [
          EntityFilterBar(
            filter: state.filter,
            onChanged: ref.read(adminDeliverySlotsControllerProvider.notifier).setFilter,
            searchHint: 'Search slots by name',
          ),
          if (!state.loading || !state.paginated.isEmpty)
            ListCountLine(
              total: state.paginated.total,
              singular: 'delivery slot',
              plural: 'delivery slots',
            ),
          Expanded(
            child: state.loading && state.paginated.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.paginated.isEmpty
                    ? EmptyState(
                        icon: Icons.access_time,
                        title: 'No delivery slots found',
                        message: state.error?.message,
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(adminDeliverySlotsControllerProvider.notifier).refresh(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 4, bottom: 90),
                          itemCount: state.paginated.items.length + (state.loadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.paginated.items.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            final slot = state.paginated.items[index];

                            return DeliverySlotListTile(
                              slot: slot,
                              onTap: () => _openForm(existing: slot),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Slot'),
      ),
      bottomNavigationBar: const ShellTabBar(),
    );
  }
}
