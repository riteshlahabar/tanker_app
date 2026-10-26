import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/list_count_line.dart';
import '../../../../shared/widgets/shell_tab_bar.dart';
import '../../domain/admin_customer.dart';
import '../providers/admin_customers_controller.dart';
import '../widgets/customer_list_tile.dart';
import '../widgets/entity_filter_bar.dart';
import 'customer_form_screen.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(adminCustomersControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openForm({AdminCustomer? existing}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CustomerFormScreen(existing: existing)),
    );

    await ref.read(adminCustomersControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminCustomersControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: Column(
        children: [
          EntityFilterBar(
            filter: state.filter,
            onChanged: ref.read(adminCustomersControllerProvider.notifier).setFilter,
            searchHint: 'Search by name or mobile',
          ),
          if (!state.loading || !state.paginated.isEmpty)
            ListCountLine(
              total: state.paginated.total,
              singular: 'customer',
              plural: 'customers',
            ),
          Expanded(
            child: state.loading && state.paginated.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.paginated.isEmpty
                    ? EmptyState(
                        icon: Icons.people_outline,
                        title: 'No customers found',
                        message: state.error?.message,
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(adminCustomersControllerProvider.notifier).refresh(),
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

                            final customer = state.paginated.items[index];

                            return CustomerListTile(
                              customer: customer,
                              onTap: () => _openForm(existing: customer),
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
        label: const Text('Add Customer'),
      ),
      bottomNavigationBar: const ShellTabBar(),
    );
  }
}
