import 'package:firebase_auth/firebase_auth.dart';

/// Base abstract class representing a generic user.
///
/// This class encapsulates a [User] instance from Firebase
/// and provides common properties to access information
/// such as email and UID.
abstract class GenericUser {
  /// The Firebase [User] instance.
  final User user;

  /// Constructor to create a [GenericUser] instance.
  ///
  /// Requires a Firebase [User] as a parameter.
  GenericUser({required this.user});

  /// Returns the email of the user.
  ///
  /// If the email is not available, it returns `null`.
  String? get email => user.email;

  /// Returns the unique UID of the user.
  String get uid => user.uid;
}

/* ------------------- ADMIN ------------------------ */

/// Class representing an Admin.
///
/// Extends [GenericUser] to provide a representation of a user
/// with global administrator privileges.
class Admin extends GenericUser {
  /// Constructor to create a [Admin] instance.
  ///
  /// Requires a Firebase [User] as a parameter.
  Admin({required super.user});
}

/* -------------------- MUNICIPALITY -------------------- */

/// Class representing a Municipality.
///
/// Extends [GenericUser] to add specific properties
/// such as the municipality name, and province.
class Municipality extends GenericUser {
  /// The name of the municipality associated with this user.
  final String? municipalityName;

  /// The province where the municipality is located.
  final String? province;

  /// Constructor to create a [Municipality] instance.
  ///
  /// Requires a Firebase [User] as a parameter, with optional [password],
  /// [municipality], and [province] fields.
  Municipality({
    required super.user,
    this.municipalityName,
    this.province,
  });
}

/* ------------------- CITIZEN --------------------- */

/// Class representing a Citizen.
///
/// Extends [GenericUser] to add specific properties
/// such as the first name, last name, address, and other personal details.
class Citizen extends GenericUser {
  static const _addressKeys = ['street', 'number'];

  /// The first name of the citizen.
  final String? firstName;

  /// The last name of the citizen.
  final String? lastName;

  /// The address of the citizen.
  final Map<String, String>? address;

  /// The city of residence of the citizen.
  final String? city;

  /// The postal code (ZIP) of the citizen's residence.
  final String? cap;

  /// Constructor to create a [Citizen] instance.
  ///
  /// Requires a Firebase [User] as a parameter, with optional
  /// personal information such as [username], [password], [name],
  /// [surname], [address], [city], and [cap].
  Citizen({
    required super.user,
    this.firstName,
    this.lastName,
    this.city,
    this.cap,
    Map<String, String>? address,
  }) : address = _validateAddress(address);

  /// Validates the provided address map.
  ///
  /// This method ensures that the provided address map contains only the valid keys
  /// specified in the `_addressKeys` list (`street` and `number`). If the map contains
  /// additional keys, missing keys, or is null, the method returns `null`. If the map
  /// is valid, it returns the original map without modification.
  ///
  /// This validation is useful to ensure that the address data adheres to a predefined structure.
  ///
  /// Example:
  /// ```dart
  /// Map<String, String>? validAddress = {'street': 'Main St', 'number': '123'};
  /// Map<String, String>? invalidAddress = {'street': 'Main St', 'city': 'Springfield'};
  ///
  /// print(Citizen._validateAddress(validAddress)); // {street: Main St, number: 123}
  /// print(Citizen._validateAddress(invalidAddress)); // null
  /// print(Citizen._validateAddress(null)); // null
  /// ```
  ///
  /// \param address The address map to validate, which can be null.
  ///
  /// \return The original map if valid, or `null` if the input is invalid.
  ///
  /// \throws No exceptions are thrown by this method.
  static Map<String, String>? _validateAddress(Map<String, String>? address) {
    if (address == null) {
      return null;
    }

    if (address.keys.toSet().containsAll(_addressKeys.toSet()) &&
        address.keys.length == _addressKeys.length) {
      return address;
    }

    return null;
  }
}
