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
  /// This method checks if the provided address map contains only valid keys
  /// (`street` and `number`). If any invalid key is found, an `ArgumentError`
  /// is thrown. The method returns a new map containing only the valid keys.
  ///
  /// \param address The address map to validate.
  ///
  /// \return A new map containing only the valid keys, or `null` if the input is `null`.
  ///
  /// \throws ArgumentError if the address map contains invalid keys.
  static Map<String, String>? _validateAddress(Map<String, String>? address){
    if (address == null) {
      return null;
    }

    /// Keys Validation: Only `street` and `number` are valid keys
    final Map<String, String> validatedAddress = {};
    for (var key in address.keys) {
      if (!_addressKeys.contains(key)) {
        throw ArgumentError('Invalid address key: $key');
      }
      validatedAddress[key] = address[key]!;
    }
    return validatedAddress;
  }

}
