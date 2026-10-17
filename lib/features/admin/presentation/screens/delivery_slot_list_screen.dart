import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/entity_list_tile.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../domain/admin_delivery_slot.dart';
import '../providers/admin_delivery_slots_controller.dart';
import 'delivery_slot_form_screen.dart';

class DeliverySlotListScreen extends ConsumerStatefulWidget {
  const DeliverySlotListScreen({super.key});

  @override
  ConsumerState<DeliverySlotListScreen> createState() => _DeliverySlotListScreenState();
}

class _DeliverySlotListScreenState extends ConsumerState<DeliverySlotListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

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
    _searchController.dispose();
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search slots',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => ref
                        .read(adminDeliverySlotsControllerProvider.notifier)
                        .setFilter(state.filter.copyWith(search: value)),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<bool?>(
                  value: state.filter.status,
                  hint: const Text('Status'),
                  onChanged: (value) =>
                      ref.read(adminDeliverySlotsControllerProvider.notifier).setFilter(
                            value == null
                                ? state.filter.copyWith(clearStatus: true)
                                : state.filter.copyWith(status: value),
                          ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: true, child: Text('Active')),
                    DropdownMenuItem(value: false, child: Text('Inactive')),
                  ],
                ),
              ],
            ),
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
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: state.paginated.items.length + (state.loadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.paginated.items.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            final slot = state.paginated.items[index];

                            return EntityListTile(
                              title: slot.name,
                              subtitle: slot.label,
                              active: slot.status,
                              onTap: () => _openForm(existing: slot),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const ShellTabBar(),
    );
  }
}
