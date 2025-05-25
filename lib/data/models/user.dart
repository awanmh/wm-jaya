// lib/data/models/user.dart
class User {
  final int id;
  final String username;
  final String passwordHash;
  final String salt;
  final String role;
  final String? authToken;
  final DateTime lastLogin;

  User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.salt,
    required this.role,
    this.authToken,
    required this.lastLogin,
  });

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'] as int,
        username: map['username'] as String,
        passwordHash: map['passwordHash'] as String,
        salt: map['salt'] as String,
        role: map['role'] as String,
        authToken: map['authToken'] as String?,
        lastLogin: DateTime.parse(map['lastLogin'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'passwordHash': passwordHash,
        'salt': salt,
        'role': role,
        'authToken': authToken,
        'lastLogin': lastLogin.toIso8601String(),
      };

  User copyWith({
    int? id,
    String? username,
    String? passwordHash,
    String? salt,
    String? role,
    String? authToken,
    DateTime? lastLogin,
  }) => User(
        id: id ?? this.id,
        username: username ?? this.username,
        passwordHash: passwordHash ?? this.passwordHash,
        salt: salt ?? this.salt,
        role: role ?? this.role,
        authToken: authToken ?? this.authToken,
        lastLogin: lastLogin ?? this.lastLogin,
      );
}