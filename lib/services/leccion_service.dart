// lib/services/leccion_service.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/leccion.dart';
import 'analytics_service.dart';
import 'stream_error_logging.dart';

class LeccionService {
  /// Seams de solo test -- nunca se asignan en código de producción. Permiten
  /// probar el contrato de progreso (iniciar/avanzar/completar) contra un
  /// Firestore falso sin tocar la firma pública de ningún método.
  @visibleForTesting
  static FirebaseFirestore? debugFirestoreOverride;
  @visibleForTesting
  static String? debugUidOverride;

  static FirebaseFirestore get _db => debugFirestoreOverride ?? FirebaseFirestore.instance;
  static String get _uid => debugUidOverride ?? FirebaseAuth.instance.currentUser!.uid;
  static CollectionReference<Map<String, dynamic>> get _col => _db.collection('users').doc(_uid).collection('progresoLecciones');

  static Stream<List<ProgresoLeccion>> streamProgreso() {
    return _col.orderBy('createdAt', descending: true).snapshots().map((s) => s.docs.map(ProgresoLeccion.fromDoc).toList()).conRegistroDeErrores();
  }

  static Future<ProgresoLeccion?> obtenerProgreso(String leccionId, {String? electrodomesticoId}) async {
    final snap = await _col.where('leccionId', isEqualTo: leccionId).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return ProgresoLeccion.fromDoc(snap.docs.first);
  }

  static Future<String> iniciarOContinuar(String leccionId, {String? electrodomesticoId}) async {
    final existente = await obtenerProgreso(leccionId);
    if (existente != null) return existente.id;
    final doc = await _col.add({
      'leccionId': leccionId,
      'electrodomesticoId': ?electrodomesticoId,
      'pasoActual': 0,
      'estado': EstadoProgresoLeccion.enCurso.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    unawaited(AnalyticsService.leccionIniciada(leccionId: leccionId));
    return doc.id;
  }

  static Future<void> avanzarPaso(String progresoId, int nuevoPaso, {required bool esUltimoPaso}) async {
    await _col.doc(progresoId).update({
      'pasoActual': nuevoPaso,
      if (esUltimoPaso) 'estado': EstadoProgresoLeccion.completada.name,
      if (esUltimoPaso) 'completedAt': FieldValue.serverTimestamp(),
    });
    if (esUltimoPaso) {
      final doc = await _col.doc(progresoId).get();
      final leccionId = doc.data()?['leccionId'] as String?;
      if (leccionId != null) unawaited(AnalyticsService.leccionCompletada(leccionId: leccionId));
    }
  }
}
