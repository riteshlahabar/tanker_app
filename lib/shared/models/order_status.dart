import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// Mirrors `App\Modules\Core\Enums\OrderStatusEnum` on the panel — the value,
/// label and "is this still open" rule must all read the same as the
/// backend's, since [isOpen] gates the Cancel button.
enum OrderStatus {
  pending,
  assigned,
  refilling,
  outForDelivery,
  delivered,
  cancelled;

  static OrderStatus fromValue(String value) => switch (value) {
        'pending' => OrderStatus.pending,
        'assigned' => OrderStatus.assigned,
        'refilling' => OrderStatus.refilling,
        'out_for_delivery' => OrderStatus.outForDelivery,
        'delivered' => OrderStatus.delivered,
        'cancelled' => OrderStatus.cancelled,
        _ => OrderStatus.pending,
      };

  bool get isOpen => this != OrderStatus.delivered && this != OrderStatus.cancelled;

  Color get color => switch (this) {
        OrderStatus.pending => statusPendingColor,
        OrderStatus.assigned => statusAssignedColor,
        OrderStatus.refilling => statusRefillingColor,
        OrderStatus.outForDelivery => statusOutForDeliveryColor,
        OrderStatus.delivered => statusDeliveredColor,
        OrderStatus.cancelled => statusCancelledColor,
      };
}
