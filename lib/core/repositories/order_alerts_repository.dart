import '../network/api_result.dart';
import '../../shared/models/order.dart';

/// The buzzer's server side, as the app sees it:
/// `GET  /api/{role}/orders/alerts` and
/// `POST /api/{role}/orders/{order}/seen`.
///
/// Both roles call the same two shapes — the audience comes from the token,
/// not the URL — so there is one contract and the path prefix is chosen once,
/// where the repository is provided.
abstract interface class OrderAlertsRepository {
  /// Orders written for this user that are still open and still unseen,
  /// oldest first. Not paginated: the panel caps the list at 20, because an
  /// alert list is what is on fire now, not a backlog to scroll.
  Future<ApiResult<List<Order>>> pending();

  /// "I have looked at it." Idempotent on the panel, which keeps the first
  /// timestamp — so a Stop that lands after the order was already opened is
  /// a success, not a conflict.
  Future<ApiResult<String>> markSeen(int orderId);
}
