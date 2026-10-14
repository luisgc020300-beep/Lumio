// lib/services/electrodomestico_service.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/electrodomestico.dart';
import 'stream_error_logging.dart';

class IdentificacionResultado {
  const IdentificacionResultado({
    required this.modo,
    required this.categoria,
    this.fabricante,
    this.modelo,
    this.confianza,
    this.controlesVisibles = const [],
    this.incertidumbres = const [],
    required this.resumen,
    required this.storagePath,
  });

  final String modo; // demo | real
  final CategoriaElectrodomestico categoria;
  final String? fabricante;
  final String? modelo;
  final double? confianza;
  final List<String> controlesVisibles;
  final List<String> incertidumbres;
  final String resumen;
  /// Ruta en Storage de la foto ya subida -- se necesita para [guardar].
  final String storagePath;
}

class ElectrodomesticoService {
  static final _db = FirebaseFirestore.instance;
  static const _region = 'europe-west1';
  static String get _uid => FirebaseAuth.instance.currentUser!.uid;
  static CollectionReference<Map<String, dynamic>> get _col => _db.collection('users').doc(_uid).collection('electrodomesticos');

  static Stream<List<Electrodomestico>> streamElectrodomesticos() {
    return _col.orderBy('createdAt', descending: true).snapshots().map((s) => s.docs.map(Electrodomestico.fromDoc).toList()).conRegistroDeErrores();
  }

  static Stream<Electrodomestico?> streamElectrodomestico(String id) {
    return _col.doc(id).snapshots().map((d) => d.exists ? Electrodomestico.fromDoc(d) : null).conRegistroDeErrores();
  }

  /// Sube la foto y lanza la identificación (real si hay clave de IA
  /// configurada en el servidor, demo determinista si no la hay -- la
  /// decisión es siempre de la Cloud Function, nunca del cliente).
  static Future<IdentificacionResultado> identificar(File foto) async {
    final storagePath = 'users/$_uid/electrodomesticos/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await FirebaseStorage.instance.ref(storagePath).putFile(foto, SettableMetadata(contentType: 'image/jpeg'));

    final callable = FirebaseFunctions.instanceFor(region: _region).httpsCallable('identificarElectrodomestico');
    final result = await callable.call({'storagePath': storagePath});
    final data = Map<String, dynamic>.from(result.data as Map);

    return IdentificacionResultado(
      modo: data['mode'] as String,
      categoria: CategoriaElectrodomestico.parse(data['category'] as String?),
      fabricante: data['manufacturer'] as String?,
      modelo: data['model'] as String?,
      confianza: (data['confidence'] as num?)?.toDouble(),
      controlesVisibles: ((data['visibleControls'] as List?) ?? []).map((e) => e as String).toList(),
      incertidumbres: ((data['uncertainties'] as List?) ?? []).map((e) => e as String).toList(),
      resumen: data['summary'] as String? ?? '',
      storagePath: storagePath,
    );
  }

  static Future<String> guardar({required String nombre, required IdentificacionResultado identificacion}) async {
    final fotoUrl = await FirebaseStorage.instance.ref(identificacion.storagePath).getDownloadURL();
    final doc = await _col.add({
      ...Electrodomestico(
        id: '',
        nombre: nombre,
        categoria: identificacion.categoria,
        fabricante: identificacion.fabricante,
        modelo: identificacion.modelo,
        estadoIdentificacion: identificacion.modelo != null && (identificacion.confianza ?? 0) >= 0.6
            ? EstadoIdentificacion.identificadoConModelo
            : (identificacion.categoria != CategoriaElectrodomestico.otro ? EstadoIdentificacion.identificadoGeneral : EstadoIdentificacion.sinIdentificar),
        confianzaIdentificacion: identificacion.confianza,
        fotoUrl: fotoUrl,
        controlesVisibles: identificacion.controlesVisibles,
        incertidumbres: identificacion.incertidumbres,
      ).toMap(),
      'storagePath': identificacion.storagePath,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  static Future<void> renombrar(String id, String nuevoNombre) => _col.doc(id).update({'nombre': nuevoNombre, 'updatedAt': FieldValue.serverTimestamp()});

  static Future<void> eliminar(String id) async {
    final doc = await _col.doc(id).get();
    final storagePath = doc.data()?['storagePath'] as String?;
    if (storagePath != null) {
      try {
        await FirebaseStorage.instance.ref(storagePath).delete();
      } catch (_) {}
    }
    await _col.doc(id).delete();
  }
}
