import 'package:firebase_auth/firebase_auth.dart';

/// An enumeration of user types.
///
/// This is used to define and manage different roles within the application.
enum UserType implements Comparable<UserType> {
  /// Super Administrator (highest privileges).
  admin(value: 0, name: 'Super Administrator'),

  /// Municipality Administrator.
  municipality(value: 1, name: 'Municipality Administrator'),

  /// Regular user (citizen).
  citizen(value: 2, name: 'Regular user'),

  /// Unidentified or unauthorized user.
  unknown(value: -1, name: 'Unknown');

  /// Constructs a `UserType` with the given [value] and [name].
  const UserType({required this.value, required this.name});

  /// The integer value associated with this enum.
  final int value;

  /// The display name of this user type.
  final String name;

  @override
  int compareTo(UserType other) {
    return value - other.value;
  }
}

/// Base class representing a generic user.
///
/// This class encapsulates a [User] instance from Firebase
/// and provides common properties to access information
/// such as email and UID.
class UserGenerico {
  /// The Firebase [User] instance.
  final User user;

  UserType? _userType;

  /// Constructor to create a [UserGenerico] instance.
  ///
  /// Requires a Firebase [User] as a parameter.
  UserGenerico({required this.user});

  /// Returns the email of the user.
  ///
  /// If the email is not available, it returns `null`.
  String? get email => user.email;

  /// Returns the unique UID of the user.
  String get uid => user.uid;

  /// Set the type of user
  void setUserType(UserType userType) => _userType = userType;

  /// Get the type of user
  UserType? get userType => _userType;
}

/// Class representing a Super Admin.
///
/// Extends [UserGenerico] to provide a representation of a user
/// with global administrator privileges.
class SuperAdmin extends UserGenerico {
  /// Constructor to create a [SuperAdmin] instance.
  ///
  /// Requires a Firebase [User] as a parameter.
  SuperAdmin({required super.user});
}

/// Class representing a Municipality.
///
/// Extends [UserGenerico] to add specific properties
/// such as the municipality name, and province.
class Municipality extends UserGenerico {
  /// The name of the municipality associated with this user.
  final String? municipality;

  /// The province where the municipality is located.
  final String? province;

  /// Constructor to create a [Municipality] instance.
  ///
  /// Requires a Firebase [User] as a parameter, with optional [password],
  /// [municipality], and [province] fields.
  Municipality({
    required super.user,
    this.municipality,
    this.province,
  });
}

/// Class representing a Citizen.
///
/// Extends [UserGenerico] to add specific properties
/// such as the first name, last name, address, and other personal details.
class Citizen extends UserGenerico {
  /// The username of the citizen.
  final String? username;

  /// The first name of the citizen.
  final String? name;

  /// The last name of the citizen.
  final String? surname;

  /// The address of the citizen.
  final String? address;

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
    this.username,
    this.name,
    this.surname,
    this.address,
    this.city,
    this.cap,
  });
}
