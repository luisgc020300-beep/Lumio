// lib/services/diagnostico_service.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/diagnostico.dart';
import 'analytics_service.dart';
import 'stream_error_logging.dart';

class RespuestaDiagnostico {
  const RespuestaDiagnostico({required this.modo, required this.contenido, required this.esAvisoSeguridad, required this.estado});
  final String modo; // demo | real
  final String contenido;
  final bool esAvisoSeguridad;
  final EstadoDiagnostico estado;
}

class DiagnosticoService {
  static final _db = FirebaseFirestore.instance;
  static const _region = 'europe-west1';
  static String get _uid => FirebaseAuth.instance.currentUser!.uid;
  static CollectionReference<Map<String, dynamic>> get _sesiones => _db.collection('users').doc(_uid).collection('diagnosticos');

  static Stream<List<SesionDiagnostico>> streamSesiones() {
    return _sesiones.orderBy('updatedAt', descending: true).snapshots().map((s) => s.docs.map(SesionDiagnostico.fromDoc).toList()).conRegistroDeErrores();
  }

  static Stream<List<MensajeDiagnostico>> streamMensajes(String sesionId) {
    return _sesiones.doc(sesionId).collection('mensajes').orderBy('createdAt').snapshots().map((s) => s.docs.map(MensajeDiagnostico.fromDoc).toList()).conRegistroDeErrores();
  }

  /// Solo crea la sesión -- el primer mensaje lo escribe la llamada a
  /// [enviarMensaje] que el screen hace justo después, para no duplicarlo.
  static Future<String> crearSesion(String sintoma, {String? electrodomesticoId}) async {
    final doc = await _sesiones.add({
      'sintoma': sintoma,
      'electrodomesticoId': ?electrodomesticoId,
      'estado': EstadoDiagnostico.investigando.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    unawaited(AnalyticsService.diagnosticoIniciado(tieneElectrodomestico: electrodomesticoId != null));
    return doc.id;
  }

  static Future<void> enviarMensaje(String sesionId, String mensaje, {String? electrodomesticoId}) async {
    await _sesiones.doc(sesionId).collection('mensajes').add({'rol': 'user', 'contenido': mensaje, 'createdAt': FieldValue.serverTimestamp()});

    final historial = await _sesiones.doc(sesionId).collection('mensajes').orderBy('createdAt').get();
    final mensajes = historial.docs.map((d) => {'role': d.data()['rol'], 'content': d.data()['contenido']}).toList();

    final callable = FirebaseFunctions.instanceFor(region: _region).httpsCallable('investigarProblema');
    final result = await callable.call({'messages': mensajes, 'electrodomesticoId': ?electrodomesticoId});
    final data = Map<String, dynamic>.from(result.data as Map);

    await _sesiones.doc(sesionId).collection('mensajes').add({
      'rol': 'assistant',
      'contenido': data['content'],
      'esAvisoSeguridad': data['safetyFlag'] == true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _sesiones.doc(sesionId).update({
      'estado': EstadoDiagnostico.parse(data['status'] as String?).name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (data['tuvoHistorialPrevio'] == true) unawaited(AnalyticsService.diagnosticoConHistorialPrevio());
    if (data['safetyFlag'] == true) unawaited(AnalyticsService.avisoSeguridadMostrado());
  }
}
