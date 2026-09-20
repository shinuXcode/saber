import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// On-device note lock. No network access and no plaintext PIN storage.
class NoteLockService {
  NoteLockService._();

  static const _storage = FlutterSecureStorage();
  static const _prefix = 'sadab_note_lock_v1:';

  static String _key(String notePath) =>
      _prefix + sha256.convert(utf8.encode(notePath)).toString();

  static Future<bool> isLocked(String notePath) async =>
      (await _storage.read(key: _key(notePath))) != null;

  static Future<void> setPin(String notePath, String pin) async {
    if (!RegExp(r'^\d{4,12}$').hasMatch(pin)) {
      throw ArgumentError('PIN must contain 4 to 12 digits.');
    }
    final digest = sha256.convert(utf8.encode(pin)).toString();
    await _storage.write(key: _key(notePath), value: digest);
  }

  static Future<bool> verify(String notePath, String pin) async {
    final stored = await _storage.read(key: _key(notePath));
    if (stored == null) return true;
    return stored == sha256.convert(utf8.encode(pin)).toString();
  }

  static Future<void> remove(String notePath) async =>
      _storage.delete(key: _key(notePath));
}