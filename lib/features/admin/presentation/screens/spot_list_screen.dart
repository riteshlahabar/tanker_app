import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/spot.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/list_count_line.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../providers/admin_spots_controller.dart';
import '../widgets/entity_filter_bar.dart';
import '../widgets/spot_admin_list_tile.dart';
import 'spot_form_screen.dart';

class SpotListScreen extends ConsumerStatefulWidget {
  const SpotListScreen({super.key});

  @override
  ConsumerState<SpotListScreen> createState() => _SpotListScreenState();
}

class _SpotListScreenState extends ConsumerState<SpotListScreen> {
  final _scrollController = ScrollController();

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
      appBar: AppBar(title: const Text('Filling Points')),
      body: Column(
        children: [
          EntityFilterBar(
            filter: state.filter,
            onChanged: ref.read(adminSpotsControllerProvider.notifier).setFilter,
            searchHint: 'Search by name, address or contact',
          ),
          if (!state.loading || !state.paginated.isEmpty)
            ListCountLine(
              total: state.paginated.total,
              singular: 'filling point',
              plural: 'filling points',
            ),
          Expanded(
            child: state.loading && state.paginated.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.paginated.isEmpty
                    ? EmptyState(
                        icon: Icons.water_drop_outlined,
                        title: 'No filling points found',
                        message: state.error?.message,
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(adminSpotsControllerProvider.notifier).refresh(),
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

                            final spot = state.paginated.items[index];

                            return SpotAdminListTile(
                              spot: spot,
                              onTap: () => _openForm(existing: spot),
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
        label: const Text('Add Filling Point'),
      ),
      bottomNavigationBar: const ShellTabBar(),
    );
  }
}
