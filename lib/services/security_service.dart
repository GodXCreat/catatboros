import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService {
  final LocalAuthentication _auth = LocalAuthentication();

  String hashPin(String pin) {
    return sha256.convert(utf8.encode('catatboros-v1:$pin')).toString();
  }

  bool verifyPin(String pin, String hash) {
    return hashPin(pin) == hash;
  }

  Future<bool> canUseBiometric() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();
      return canCheck || supported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateBiometric() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Buka CatatBoros dengan biometrik perangkat',
      );
    } catch (_) {
      return false;
    }
  }
}
