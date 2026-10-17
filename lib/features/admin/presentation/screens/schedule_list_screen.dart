import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/entity_list_tile.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../providers/admin_schedules_controller.dart';
import 'schedule_detail_screen.dart';
import 'schedule_form_screen.dart';

class ScheduleListScreen extends ConsumerStatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  ConsumerState<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends ConsumerState<ScheduleListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(adminSchedulesControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _generateNow() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate tomorrow’s standing orders?'),
        content: const Text('This runs the same generator the nightly schedule does.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Generate')),
        ],
      ),
    );

    if (confirmed != true) return;

    final message = await ref.read(adminSchedulesControllerProvider.notifier).generateNow();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openCreate() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ScheduleFormScreen()));

    await ref.read(adminSchedulesControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminSchedulesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Standing Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            tooltip: 'Generate now',
            onPressed: _generateNow,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search by customer name or mobile',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) => ref
                      .read(adminSchedulesControllerProvider.notifier)
                      .setFilter(state.filter.copyWith(search: value)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    DropdownButton<bool?>(
                      value: state.filter.status,
                      hint: const Text('Status'),
                      onChanged: (value) => ref.read(adminSchedulesControllerProvider.notifier)
                          .setFilter(
                            value == null
                                ? state.filter.copyWith(clearStatus: true)
                                : state.filter.copyWith(status: value),
                          ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Any status')),
                        DropdownMenuItem(value: true, child: Text('Active')),
                        DropdownMenuItem(value: false, child: Text('Inactive')),
                      ],
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<bool?>(
                      value: state.filter.paused,
                      hint: const Text('Paused?'),
                      onChanged: (value) => ref.read(adminSchedulesControllerProvider.notifier)
                          .setFilter(
                            value == null
                                ? state.filter.copyWith(clearPaused: true)
                                : state.filter.copyWith(paused: value),
                          ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Any')),
                        DropdownMenuItem(value: true, child: Text('Paused')),
                        DropdownMenuItem(value: false, child: Text('Running')),
                      ],
                    ),
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
                        icon: Icons.schedule_outlined,
                        title: 'No standing orders found',
                        message: state.error?.message,
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(adminSchedulesControllerProvider.notifier).refresh(),
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

                            final schedule = state.paginated.items[index];

                            return EntityListTile(
                              title: schedule.customerName ?? 'Customer #${schedule.customerId}',
                              subtitle: schedule.isPaused
                                  ? '${schedule.pattern} · Paused'
                                  : schedule.pattern,
                              active: schedule.status,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ScheduleDetailScreen(scheduleId: schedule.id),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const ShellTabBar(),
    );
  }
}
