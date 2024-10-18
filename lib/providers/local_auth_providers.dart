import 'package:codigoqr/config/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final caCheckBiometricoProvider = FutureProvider<bool>((ref) async {
  return await LocalAutorizacion.canVerificarBiometrico();
});

enum LocalAuthStatus { authenticated, notAuthenticated, authenticating }

class LocalAuthEstado {
  final bool autenticacion;
  final LocalAuthStatus estado;
  final String mensaje;

  LocalAuthEstado(
      {this.autenticacion = false,
      this.estado = LocalAuthStatus.notAuthenticated,
      this.mensaje = ''});

  LocalAuthEstado copyWith({
    bool? autenticacion,
    LocalAuthStatus? estado,
    String? mensaje,
  }) =>
      LocalAuthEstado(
        autenticacion: autenticacion ?? this.autenticacion,
        estado: estado ?? this.estado,
        mensaje: mensaje ?? this.mensaje,
      );
  @override
  String toString() {
    return '''

      autenticacion: $autenticacion
      estado: $estado
      mensaje: $mensaje
    ''';
  }
}

class LocalAuthNotifier extends StateNotifier<LocalAuthEstado> {
  LocalAuthNotifier() : super(LocalAuthEstado());

  Future<(bool, String)> autenticaciondeusuario() async {
    final (autenticacion, mensaje) = await LocalAutorizacion.autenticacion();
    state = state.copyWith(
        autenticacion: autenticacion,
        mensaje: mensaje,
        estado: autenticacion
            ? LocalAuthStatus.authenticated
            : LocalAuthStatus.notAuthenticated);
    return (autenticacion, mensaje);
  }
}

final localAutorizacionProvider =
    StateNotifierProvider<LocalAuthNotifier, LocalAuthEstado>((ref) {
  return LocalAuthNotifier();
});
