import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/spot.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/entity_list_tile.dart';
import '../providers/admin_spots_controller.dart';
import 'spot_form_screen.dart';

class SpotListScreen extends ConsumerStatefulWidget {
  const SpotListScreen({super.key});

  @override
  ConsumerState<SpotListScreen> createState() => _SpotListScreenState();
}

class _SpotListScreenState extends ConsumerState<SpotListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(adminSpotsControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({Spot? existing}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SpotFormScreen(existing: existing)),
    );

    await ref.read(adminSpotsControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminSpotsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Refill Spots')),
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
                      hintText: 'Search spots',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => ref
                        .read(adminSpotsControllerProvider.notifier)
                        .setFilter(state.filter.copyWith(search: value)),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<bool?>(
                  value: state.filter.status,
                  hint: const Text('Status'),
                  onChanged: (value) => ref.read(adminSpotsControllerProvider.notifier).setFilter(
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
                        icon: Icons.water_drop_outlined,
                        title: 'No spots found',
                        message: state.error?.message,
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(adminSpotsControllerProvider.notifier).refresh(),
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

                            final spot = state.paginated.items[index];

                            return EntityListTile(
                              title: spot.name,
                              subtitle: '₹ ${spot.refillCharge.toStringAsFixed(0)} refill'
                                  '${spot.isAvailable ? '' : ' · Unavailable'}',
                              active: spot.status,
                              onTap: () => _openForm(existing: spot),
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
    );
  }
}
