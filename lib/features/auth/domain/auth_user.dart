import '../../../shared/models/user_role.dart';
import '../../../shared/utils/json_read.dart';

/// The signed-in account, as the panel's `AuthUserResource` describes it.
/// Immutable — a screen reads it, nothing edits it in place.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.role,
    required this.status,
    required this.canSelfOrder,
    this.email,
    this.mobile,
    this.address,
    this.monthlySalary,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final UserRole? role;
  final bool status;

  /// False for a standing-order customer whose deliveries the office
  /// manages — the app refuses to show them an order form rather than
  /// letting a submit fail with the backend's refusal message.
  final bool canSelfOrder;
  final String? email;
  final String? mobile;
  final String? address;

  /// `num` on the wire, so read through [JsonRead.asDoubleOrNull] — an
  /// integral value arrives as an `int` and `as double` would throw.

  /// What a driver is paid each month. Null for an admin or a customer, which
  /// is why it is nullable rather than zero — the Profile screen is shared by
  /// all three roles and has to tell "not a driver" from "paid nothing".
  final double? monthlySalary;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: JsonRead.asInt(json['id']),
        firstName: JsonRead.asString(json['first_name']),
        lastName: JsonRead.asString(json['last_name']),
        fullName: JsonRead.asString(json['full_name']),
        role: UserRole.tryParse(JsonRead.asStringOrNull(json['role'])),
        status: JsonRead.asBool(json['status'], fallback: true),
        canSelfOrder: JsonRead.asBool(json['can_self_order'], fallback: true),
        email: JsonRead.asStringOrNull(json['email']),
        mobile: JsonRead.asStringOrNull(json['mobile']),
        address: JsonRead.asStringOrNull(json['address']),
        monthlySalary: JsonRead.asDoubleOrNull(json['monthly_salary']),
      );

  /// Initials for the avatar circle, which is all the design shows.
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    final initials = '$first$last'.trim();

    return initials.isEmpty ? '?' : initials.toUpperCase();
  }
}
