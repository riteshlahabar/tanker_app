/// The three roles the one `users` table holds. The app has a single login
/// screen and opens the shell this names.
enum UserRole {
  admin('admin'),
  driver('driver'),
  customer('customer');

  const UserRole(this.value);

  final String value;

  static UserRole? tryParse(String? value) {
    if (value == null) return null;

    for (final role in UserRole.values) {
      if (role.value == value) return role;
    }

    return null;
  }

  /// The admin signs in with an email address; a driver or customer with a
  /// mobile number. The login screen uses this to label the one field.
  bool get signsInWithEmail => this == UserRole.admin;

  String get label => switch (this) {
        UserRole.admin => 'Owner',
        UserRole.driver => 'Driver',
        UserRole.customer => 'Customer',
      };
}
