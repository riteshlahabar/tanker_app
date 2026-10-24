import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/list_count_line.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../domain/admin_tanker.dart';
import '../providers/admin_tankers_controller.dart';
import '../widgets/entity_filter_bar.dart';
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
          EntityFilterBar(
            filter: state.filter,
            onChanged: notifier.setFilter,
            searchHint: 'Search by number, name or RC',
          ),
          if (!state.loading || !state.paginated.isEmpty)
            ListCountLine(total: state.paginated.total, singular: 'tanker', plural: 'tankers'),
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
