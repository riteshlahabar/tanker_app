import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/customer_picker_controller.dart';
import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/app_search_field.dart';
import '../../../../shared/widgets/sheet_body.dart';

/// Choose which customer a report is narrowed to.
///
/// The sibling of [DriverFilterSheet], and deliberately not the shared
/// `CustomerPickerField`: that one hands back a `CustomerOption` to be
/// ordered for, while a filter only needs an id and a name to put on a chip.
/// It reads the same provider, so it opens on the full customer list and
/// narrows as you type.
class CustomerFilterSheet extends ConsumerStatefulWidget {
  const CustomerFilterSheet({super.key});

  @override
  ConsumerState<CustomerFilterSheet> createState() => _CustomerFilterSheetState();
}

class _CustomerFilterSheetState extends ConsumerState<CustomerFilterSheet> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Opens on everybody, so the filter can be set by scrolling rather than
    // only by remembering a name.
    ref.read(customerPickerControllerProvider.notifier).loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerPickerControllerProvider);

    return SheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Which customer?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          AppSearchField(
            controller: _searchController,
            hint: 'Search by name or mobile',
            onSubmitted: (value) =>
                ref.read(customerPickerControllerProvider.notifier).search(value),
          ),
          const SizedBox(height: 10),
          _Row(
            title: 'All customers',
            subtitle: 'Everybody together',
            tint: appColorPrimary,
            onTap: () => Navigator.pop<({int? id, String label})>(
              context,
              (id: null, label: 'All customers'),
            ),
          ),
          if (state.loading) const LinearProgressIndicator(minHeight: 2),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                state.error!.message,
                style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.error),
              ),
            ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final customer in state.options)
                  _Row(
                    title: customer.fullName,
                    subtitle: customer.mobile ?? customer.address ?? '—',
                    tint: appetitBrownColor,
                    onTap: () => Navigator.pop<({int? id, String label})>(
                      context,
                      (id: customer.id, label: customer.fullName),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One row, drawn as a small version of the app's cream card rather than
/// Material's white `ListTile` — the same anatomy [DriverFilterSheet] uses.
class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color:
            isDark ? Theme.of(context).cardColor : appetitAppContainerColor.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(13),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.person_outline, size: 19, color: tint),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: appTextColorSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
