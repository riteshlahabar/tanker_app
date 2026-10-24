import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/list_count_line.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../domain/admin_driver.dart';
import '../providers/admin_drivers_controller.dart';
import '../widgets/driver_list_tile.dart';
import '../widgets/entity_filter_bar.dart';
import 'driver_form_screen.dart';

class DriverListScreen extends ConsumerStatefulWidget {
  const DriverListScreen({super.key});

  @override
  ConsumerState<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends ConsumerState<DriverListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(adminDriversControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openForm({AdminDriver? existing}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DriverFormScreen(existing: existing)),
    );

    await ref.read(adminDriversControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminDriversControllerProvider);
    final notifier = ref.read(adminDriversControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Drivers')),
      body: Column(
        children: [
          EntityFilterBar(
            filter: state.filter,
            onChanged: notifier.setFilter,
            searchHint: 'Search by name or mobile',
          ),
          if (!state.loading || !state.paginated.isEmpty)
            ListCountLine(total: state.paginated.total, singular: 'driver', plural: 'drivers'),
          Expanded(
            child: state.loading && state.paginated.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.paginated.isEmpty
                    ? EmptyState(
                        icon: Icons.badge_outlined,
                        title: 'No drivers found',
                        message: state.error?.message,
                      )
                    : RefreshIndicator(
                        onRefresh: notifier.refresh,
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

                            final driver = state.paginated.items[index];

                            return DriverListTile(
                              driver: driver,
                              onTap: () => _openForm(existing: driver),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      // Labelled rather than a bare +: this screen also holds a search field
      // and two filter chips, so what the button adds should be said.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Add Driver'),
      ),
      bottomNavigationBar: const ShellTabBar(),
    );
  }
}
