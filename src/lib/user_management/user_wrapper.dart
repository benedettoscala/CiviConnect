import 'package:firebase_auth/firebase_auth.dart';

/// A wrapper class for user data that handles different initialization scenarios:
/// 1. From a Firebase user instance.
/// 2. From a login (email and password).
/// 3. From a registration (complete user details).
class UserWrapper {
  final User? _user;
  final String? _email;
  final String? _username;
  final String? _password;
  final String? _name;
  final String? _surname;
  final Map<String,String>? _address;
  final String? _city;
  final String? _cap;

  /// Private constructor to initialize the class.
  ///
  /// This constructor is only accessible through factory constructors
  /// for specific use cases (Firebase, login, registration).
  UserWrapper._({
    required User? user,
    String? email,
    String? username,
    String? password,
    String? name,
    String? surname,
    Map<String, String>? address,
    String? city,
    String? cap,
  })  : _user = user,
        _email = email,
        _username = username,
        _password = password,
        _name = name,
        _surname = surname,
        _address = address,
        _city = city,
        _cap = cap;

  /// Creates a [UserWrapper] from a [User] instance provided by Firebase.
  ///
  /// This factory is typically used when user information is retrieved from
  /// Firebase Authentication. It initializes the wrapper with the
  /// Firebase [User] and derives the email from it.
  ///
  /// Example:
  /// ```dart
  /// UserWrapper user = UserWrapper.fromFirebaseUser(firebaseUser);
  /// ```
  factory UserWrapper.fromFirebaseUser(User user) {
    return UserWrapper._(user: user, email: user.email);
  }

  /// Creates a [UserWrapper] for login scenarios.
  ///
  /// This factory is used when the user is logging in and only
  /// email and password are available.
  ///
  /// Example:
  /// ```dart
  /// UserWrapper user = UserWrapper.fromLogin(email: 'example@example.com', password: 'securePassword');
  /// ```
  ///
  /// [email] and [password] must be provided.
  factory UserWrapper.fromLogin(
      {required String email, required String password}) {
    return UserWrapper._(email: email, password: password, user: null);
  }

  /// Creates a [UserWrapper] for registration scenarios.
  ///
  /// This factory is used when the user is registering and all user details
  /// (e.g., email, username, password, name, surname, address, city, cap)
  /// are provided.
  ///
  /// Example:
  /// ```dart
  /// UserWrapper user = UserWrapper.fromRegistration(
  ///   email: 'example@example.com',
  ///   username: 'username123',
  ///   password: 'securePassword',
  ///   name: 'John',
  ///   surname: 'Doe',
  ///   address: '123 Main St',
  ///   city: 'Metropolis',
  ///   cap: '12345',
  /// );
  /// ```
  ///
  /// All parameters are required.
  factory UserWrapper.fromRegistration({
    required String email,
    required String username,
    required String password,
    required String name,
    required String surname,
    required Map<String, String> address,
    required String city,
    required String cap,
  }) {
    return UserWrapper._(
      email: email,
      username: username,
      password: password,
      name: name,
      surname: surname,
      address: address,
      city: city,
      cap: cap,
      user: null,
    );
  }

  /// Returns the Firebase UID of the user.
  ///
  /// Throws a [StateError] if the wrapper does not contain a Firebase [User].
  ///
  /// Example:
  /// ```dart
  /// String uid = user.uid;
  /// ```
  String get uid {
    if (_user == null) {
      throw StateError('UID is not available without a Firebase User.');
    }
    return _user.uid;
  }

  /// Returns the email address of the user.
  ///
  /// If the wrapper contains a Firebase [User], the email is derived from it.
  /// Otherwise, it returns the email initialized in the wrapper.
  ///
  /// Example:
  /// ```dart
  /// String email = user.email;
  /// ```
  String get email => _email ?? _user?.email ?? 'Email not available';

  /// Returns the username of the user.
  ///
  /// Returns `null` if the username was not provided during initialization.
  String? get username => _username;

  /// Returns the password of the user.
  ///
  /// Returns `null` if the password was not provided during initialization.
  String? get password => _password;

  /// Returns the name of the user.
  ///
  /// Returns `null` if the name was not provided during initialization.
  String? get name => _name;

  /// Returns the surname of the user.
  ///
  /// Returns `null` if the surname was not provided during initialization.
  String? get surname => _surname;

  /// Returns the address of the user.
  ///
  /// Returns `null` if the address was not provided during initialization.
  Map<String, String>? get address => _address;

  /// Returns the city of the user.
  ///
  /// Returns `null` if the city was not provided during initialization.
  String? get city => _city;

  /// Returns the postal code (CAP) of the user.
  ///
  /// Returns `null` if the postal code was not provided during initialization.
  String? get cap => _cap;

  /// Indicates whether the wrapper contains a Firebase [User].
  ///
  /// Returns `true` if a Firebase [User] is present, otherwise `false`.
  ///
  /// Example:
  /// ```dart
  /// if (user.isFirebaseUser) {
  ///   print('This is a Firebase user.');
  /// }
  /// ```
  bool get isFirebaseUser => _user != null;
}
