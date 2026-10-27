import 'package:flutter/material.dart';

import '../../../../shared/models/spot.dart';
import '../../../../shared/widgets/app_dropdown_field.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/form_note.dart';
import '../../../../shared/widgets/sheet_body.dart';

/// What the driver filled in before starting the refill.
class RefillChoice {
  const RefillChoice({required this.spotId, this.note});

  /// Always a real spot. The sheet is only ever opened when a filling point
  /// has to be *named* — either because the admin named none, or because the
  /// driver is changing the one they did — so "leave it as it is" is not an
  /// outcome of this sheet, it is not opening it.
  final int spotId;

  final String? note;
}

/// Asks the driver which filling point they are at.
///
/// Opened from two places and the wording follows which: with no filling
/// point on the order it is the Start Refill step itself, and with one it is
/// a deliberate change. Either way a spot must be picked before the button
/// enables — the sheet used to offer "Use the assigned filling point" as a
/// null option, which made it possible to confirm the sheet and change
/// nothing, so it was asking a question that had no answer.
Future<RefillChoice?> showRefillSpotSheet(
  BuildContext context, {
  required List<Spot> options,
  int? currentSpotId,
  required bool changing,
}) {
  return showModalBottomSheet<RefillChoice>(
    context: context,
    // Without this the sheet is capped at 9/16 of the screen and the note
    // field lands under the fold once the keyboard is up.
    isScrollControlled: true,
    builder: (sheetContext) => _RefillSpotSheet(
      options: options,
      currentSpotId: currentSpotId,
      changing: changing,
    ),
  );
}

class _RefillSpotSheet extends StatefulWidget {
  const _RefillSpotSheet({
    required this.options,
    required this.currentSpotId,
    required this.changing,
  });

  final List<Spot> options;
  final int? currentSpotId;
  final bool changing;

  @override
  State<_RefillSpotSheet> createState() => _RefillSpotSheetState();
}

class _RefillSpotSheetState extends State<_RefillSpotSheet> {
  late int? _spotId = widget.options.any((spot) => spot.id == widget.currentSpotId)
      ? widget.currentSpotId
      : null;

  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _confirm() {
    final spotId = _spotId;

    if (spotId == null) return;

    Navigator.pop(
      context,
      RefillChoice(spotId: spotId, note: _noteController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final empty = widget.options.isEmpty;

    return SheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.changing ? 'Change filling point' : 'Start refill',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (empty)
            const FormNote(
              'No filling point is available right now. Ask the office to mark '
              'one available, then try again.',
            )
          else ...[
            AppDropdownField<int>(
              label: 'Filling point',
              value: _spotId,
              icon: Icons.local_drink_outlined,
              items: widget.options
                  .map((spot) => DropdownMenuItem(value: spot.id, child: Text(spot.name)))
                  .toList(),
              onChanged: (value) => setState(() => _spotId = value),
            ),
            const SizedBox(height: 6),
            FormNote(
              widget.changing
                  ? 'The refill charge is taken from the point you pick here, not the one the office chose.'
                  : 'Pick the point you are filling at — its refill charge goes on this order.',
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _noteController,
              label: 'Note (optional)',
              hint: 'Anything the office should know',
              maxLines: 2,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                // Null until a point is chosen: the driver cannot start a
                // refill the order has no filling point for.
                onPressed: _spotId == null ? null : _confirm,
                child: const Text('Start Refill'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
