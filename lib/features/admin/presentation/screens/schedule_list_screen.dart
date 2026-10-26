import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/list_count_line.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../domain/admin_schedule_filter.dart';
import '../providers/admin_schedules_controller.dart';
import '../widgets/schedule_list_tile.dart';
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
          _ScheduleFilterBar(
            filter: state.filter,
            controller: _searchController,
            onChanged: ref.read(adminSchedulesControllerProvider.notifier).setFilter,
          ),
          if (!state.loading || !state.paginated.isEmpty)
            ListCountLine(
              total: state.paginated.total,
              singular: 'standing order',
              plural: 'standing orders',
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
                          padding: const EdgeInsets.only(top: 4, bottom: 90),
                          itemCount: state.paginated.items.length + (state.loadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.paginated.items.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            final schedule = state.paginated.items[index];

                            return ScheduleListTile(
                              schedule: schedule,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('Add Standing Order'),
      ),
      bottomNavigationBar: const ShellTabBar(),
    );
  }
}

/// Search plus status plus paused, in [EntityFilterBar]'s idiom.
///
/// Not that widget itself: the standing-order list filters on `paused` as
/// well, which is a third state no other master-data list has, and bending the
/// shared bar to carry an optional extra pair of chips would complicate five
/// screens to serve one.
class _ScheduleFilterBar extends StatelessWidget {
  const _ScheduleFilterBar({
    required this.filter,
    required this.controller,
    required this.onChanged,
  });

  final AdminScheduleFilter filter;
  final TextEditingController controller;
  final ValueChanged<AdminScheduleFilter> onChanged;

  bool get _isFiltered =>
      filter.status != null || filter.paused != null || (filter.search?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by customer name or mobile',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              filled: true,
              fillColor: appetitAppContainerColor.withValues(alpha: 0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) => onChanged(filter.copyWith(search: value)),
          ),
          const SizedBox(height: 8),
          // Horizontally scrolled, not a fixed Row: four chips and a Clear are
          // wider than a narrow phone, and a fixed Row overflows rather than
          // scrolling.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Chip(
                  label: 'Active',
                  color: statusDeliveredColor,
                  selected: filter.status == true,
                  onTap: () => onChanged(
                    filter.status == true
                        ? filter.copyWith(clearStatus: true)
                        : filter.copyWith(status: true),
                  ),
                ),
                const SizedBox(width: 8),
                _Chip(
                  label: 'Inactive',
                  color: statusCancelledColor,
                  selected: filter.status == false,
                  onTap: () => onChanged(
                    filter.status == false
                        ? filter.copyWith(clearStatus: true)
                        : filter.copyWith(status: false),
                  ),
                ),
                const SizedBox(width: 8),
                _Chip(
                  label: 'Paused',
                  color: statusPendingColor,
                  selected: filter.paused == true,
                  onTap: () => onChanged(
                    filter.paused == true
                        ? filter.copyWith(clearPaused: true)
                        : filter.copyWith(paused: true),
                  ),
                ),
                const SizedBox(width: 8),
                _Chip(
                  label: 'Running',
                  color: appColorPrimary,
                  selected: filter.paused == false,
                  onTap: () => onChanged(
                    filter.paused == false
                        ? filter.copyWith(clearPaused: true)
                        : filter.copyWith(paused: false),
                  ),
                ),
                if (_isFiltered) ...[
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    onPressed: () {
                      controller.clear();
                      onChanged(const AdminScheduleFilter());
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      selectedColor: color.withValues(alpha: 0.14),
      side: BorderSide(color: selected ? color.withValues(alpha: 0.5) : Colors.black12),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        color: selected ? color : appTextColorPrimary,
      ),
    );
  }
}
