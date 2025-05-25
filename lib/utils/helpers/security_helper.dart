import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:wm_jaya/data/models/user.dart';

class SecurityHelper {
  static String generateSalt([int length = 32]) {
    final random = Random.secure();
    final saltBytes = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

    static bool validatePassword(User user, String inputPassword) {
    final hashedInput = hashPassword(inputPassword, user.salt);
    return hashedInput == user.passwordHash;
  }

}