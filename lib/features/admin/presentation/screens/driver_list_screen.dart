import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/entity_list_tile.dart';
import '../../domain/admin_driver.dart';
import '../providers/admin_drivers_controller.dart';
import 'driver_form_screen.dart';

class DriverListScreen extends ConsumerStatefulWidget {
  const DriverListScreen({super.key});

  @override
  ConsumerState<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends ConsumerState<DriverListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

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
    _searchController.dispose();
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

    return Scaffold(
      appBar: AppBar(title: const Text('Drivers')),
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
                      hintText: 'Search drivers',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => ref
                        .read(adminDriversControllerProvider.notifier)
                        .setFilter(state.filter.copyWith(search: value)),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<bool?>(
                  value: state.filter.status,
                  hint: const Text('Status'),
                  onChanged: (value) => ref.read(adminDriversControllerProvider.notifier).setFilter(
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
                        icon: Icons.badge_outlined,
                        title: 'No drivers found',
                        message: state.error?.message,
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(adminDriversControllerProvider.notifier).refresh(),
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

                            final driver = state.paginated.items[index];

                            return EntityListTile(
                              title: driver.fullName,
                              subtitle: '${driver.mobile}'
                                  '${driver.tanker != null ? ' · ${driver.tanker!.label}' : ' · No tanker'}',
                              active: driver.status,
                              onTap: () => _openForm(existing: driver),
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
