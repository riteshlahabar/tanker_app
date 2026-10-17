import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../domain/admin_tanker.dart';
import '../providers/admin_tankers_controller.dart';
import '../widgets/tanker_filter_bar.dart';
import '../widgets/tanker_list_tile.dart';
import 'tanker_form_screen.dart';

class TankerListScreen extends ConsumerStatefulWidget {
  const TankerListScreen({super.key});

  @override
  ConsumerState<TankerListScreen> createState() => _TankerListScreenState();
}

class _TankerListScreenState extends ConsumerState<TankerListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(adminTankersControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openForm({AdminTanker? existing}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TankerFormScreen(existing: existing)),
    );

    await ref.read(adminTankersControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminTankersControllerProvider);
    final notifier = ref.read(adminTankersControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Tankers')),
      body: Column(
        children: [
          TankerFilterBar(filter: state.filter, onChanged: notifier.setFilter),
          if (!state.loading || !state.paginated.isEmpty)
            _CountLine(total: state.paginated.total),
          Expanded(
            child: state.loading && state.paginated.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.paginated.isEmpty
                    ? EmptyState(
                        icon: Icons.local_shipping_outlined,
                        title: 'No tankers found',
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

                            final tanker = state.paginated.items[index];

                            return TankerListTile(
                              tanker: tanker,
                              onTap: () => _openForm(existing: tanker),
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
        label: const Text('Add Tanker'),
      ),
      bottomNavigationBar: const ShellTabBar(),
    );
  }
}

/// How many tankers the current filters match. Without it the list is just
/// "some tankers" — the count is what tells the owner whether a filter did
/// what they expected. Same line as the Orders screen's.
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
          total == 1 ? '1 tanker' : '$total tankers',
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
