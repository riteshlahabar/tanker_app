import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../shared/widgets/sheet_body.dart';
import '../../domain/driver_option.dart';
import '../providers/admin_picker_controllers.dart';

/// What the sheet came back with: a driver, or "all drivers".
class ExpenseDriverChoice {
  const ExpenseDriverChoice({this.id, this.name});

  const ExpenseDriverChoice.any() : id = null, name = null;

  final int? id;
  final String? name;

  bool get isAny => id == null;
}

/// Choose whose expenses to show.
///
/// Deliberately **not** the shared [DriverPickerSheet]: that one exists to
/// pick a driver who will *take an order*, so it disables anyone holding no
/// tanker. A driver with no current tanker can still have spent money last
/// month, and hiding their rows behind a disabled row would make the total
/// above the list impossible to reconcile. Every driver is selectable here,
/// and the tanker is shown as context rather than a condition.
///
/// It returns the **name** with the id so the filter chip and the totals card
/// can say whose figure is on screen.
class ExpenseDriverPickerSheet extends ConsumerStatefulWidget {
  const ExpenseDriverPickerSheet({super.key});

  @override
  ConsumerState<ExpenseDriverPickerSheet> createState() => _ExpenseDriverPickerSheetState();
}

class _ExpenseDriverPickerSheetState extends ConsumerState<ExpenseDriverPickerSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverPickerControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Whose expenses?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (value) =>
                  ref.read(driverPickerControllerProvider.notifier).search(value),
              decoration: InputDecoration(
                hintText: 'Search drivers',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13.5),
                prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                border: InputBorder.none,
                filled: true,
                fillColor: isDark
                    ? Theme.of(context).cardColor
                    : appetitAppContainerColor.withValues(alpha: 0.6),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _AnyDriverRow(
            onTap: () => Navigator.pop(context, const ExpenseDriverChoice.any()),
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
          // Flexible plus a shrink-wrapped list: the sheet grows with the
          // results rather than being clipped at a fixed height, and still
          // scrolls once there are more drivers than fit.
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final driver in state.options) _DriverRow(driver: driver),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnyDriverRow extends StatelessWidget {
  const _AnyDriverRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SheetRow(
      onTap: onTap,
      leading: const Icon(Icons.groups_outlined, size: 20, color: appColorPrimary),
      leadingTint: appColorPrimary,
      title: 'All drivers',
      subtitle: 'Everybody’s spending together',
    );
  }
}

class _DriverRow extends StatelessWidget {
  const _DriverRow({required this.driver});

  final DriverOption driver;

  @override
  Widget build(BuildContext context) {
    final initial = driver.fullName.isEmpty ? '?' : driver.fullName.substring(0, 1).toUpperCase();

    return _SheetRow(
      onTap: () => Navigator.pop(
        context,
        ExpenseDriverChoice(id: driver.id, name: driver.fullName),
      ),
      leading: Text(
        initial,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: appetitBrownColor,
        ),
      ),
      leadingTint: appetitBrownColor,
      title: driver.fullName,
      // The tanker is context, never a condition — see the class comment.
      subtitle: driver.tankerLabel ?? 'No tanker assigned',
    );
  }
}

/// One row of the sheet, drawn as a small version of the app's cream card so
/// the sheet does not fall back to Material's white `ListTile`.
class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.onTap,
    required this.leading,
    required this.leadingTint,
    required this.title,
    required this.subtitle,
  });

  final VoidCallback onTap;
  final Widget leading;
  final Color leadingTint;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isDark
            ? Theme.of(context).cardColor
            : appetitAppContainerColor.withValues(alpha: 0.45),
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
                    color: leadingTint.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: leading,
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
