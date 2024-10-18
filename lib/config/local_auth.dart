import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class LocalAutorizacion {
  static final LocalAuthentication auth = LocalAuthentication();

  static disponibilidadBiometrico() async {
    final List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    if (availableBiometrics.isNotEmpty) {
      // Some biometrics are enrolled.
    }

    if (availableBiometrics.contains(BiometricType.strong) ||
        availableBiometrics.contains(BiometricType.face)) {
      // Specific types of biometrics are available.
      // Use checks like this with caution!
    }
  }

  static Future<bool> canVerificarBiometrico() async {
    // verificar en la primera pantalla si el dispositivo tiene biometrico
    return await auth.canCheckBiometrics;
  }

  static Future<(bool, String)> autenticacion() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Por Favor autenticate para continuar',
          options: const AuthenticationOptions(
              // biometricOnly: true // podemos colocar el pin para desbloquearlo
              ));

      return (
        didAuthenticate,
        didAuthenticate ? 'Hecho' : 'Cancelado por el usuario'
      );
    } on PlatformException catch (e) {
      print(e);
      if (e.code == auth_error.notEnrolled)
        return (false, 'No hay Biometricos Enrrollados');
      if (e.code == auth_error.lockedOut)
        return (false, 'Muchos intentos Fallidos');
      if (e.code == auth_error.notAvailable)
        return (false, 'No hay Biometricos Disponibles');
      if (e.code == auth_error.passcodeNotSet)
        return (false, 'No hay un PIN configurado');
      if (e.code == auth_error.permanentlyLockedOut)
        return (false, 'Se requiere desbloquear el telefono de nuevo');

      return (false, e.toString());
    }
  }
}
