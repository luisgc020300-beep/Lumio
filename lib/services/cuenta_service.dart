// lib/services/cuenta_service.dart
import 'package:firebase_auth/firebase_auth.dart';

/// "Eliminar cuenta" solo borra la credencial de Auth desde el cliente --
/// si borráramos primero los datos de Firestore/Storage y LUEGO fallara
/// esta llamada (p. ej. "requires-recent-login", muy común en esta
/// operación), el usuario se quedaría con la cuenta viva pero sin ningún
/// dato. La limpieza de electrodomésticos/fotos/diagnósticos/progreso la
/// hace la Cloud Function `limpiarDatosUsuario` (trigger de Auth,
/// functions/index.js) DESPUÉS de que el borrado de la cuenta ya sea un
/// hecho consumado -- con privilegios de administrador, sin depender de
/// que el cliente siga autenticado.
class CuentaService {
  static Future<void> eliminarCuentaYDatos() async {
    await FirebaseAuth.instance.currentUser!.delete();
  }
}
