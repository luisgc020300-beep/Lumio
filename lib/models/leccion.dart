// lib/models/leccion.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'electrodomestico.dart';

enum TipoPasoLeccion { explicacion, visual, tarea, comprobacion, resumen }

class PasoLeccion {
  const PasoLeccion({required this.tipo, required this.titulo, required this.cuerpo, this.imagenAsset, this.porQueImporta});

  final TipoPasoLeccion tipo;
  final String titulo;
  final String cuerpo;
  /// Asset local empaquetado con la app (contenido curado, no generado) --
  /// nunca una foto real del aparato del usuario en lecciones de catálogo.
  final String? imagenAsset;
  /// "Por qué importa" -- el principio central del producto: explicar el
  /// motivo, no solo el paso.
  final String? porQueImporta;

  factory PasoLeccion.fromMap(Map<String, dynamic> m) => PasoLeccion(
        tipo: TipoPasoLeccion.values.firstWhere((t) => t.name == m['tipo'], orElse: () => TipoPasoLeccion.explicacion),
        titulo: m['titulo'] as String? ?? '',
        cuerpo: m['cuerpo'] as String? ?? '',
        imagenAsset: m['imagenAsset'] as String?,
        porQueImporta: m['porQueImporta'] as String?,
      );
}

/// Lección de catálogo: contenido curado y versionado, NO generado por IA
/// en el momento -- el brief es explícito en no rellenar la biblioteca con
/// contenido falso. El catálogo inicial vive en lib/data/catalogo_lecciones.dart.
class Leccion {
  const Leccion({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.objetivo,
    required this.nivel,
    required this.pasos,
    this.applianceEspecifico = false,
  });

  final String id;
  final String titulo;
  final CategoriaElectrodomestico categoria;
  final String objetivo;
  final String nivel; // principiante | con_base | avanzado
  final List<PasoLeccion> pasos;
  /// true si requiere un electrodoméstico concreto guardado (no aplica a
  /// lecciones generales de categoría).
  final bool applianceEspecifico;
}

enum EstadoProgresoLeccion { enCurso, completada }

class ProgresoLeccion {
  const ProgresoLeccion({
    required this.id,
    required this.leccionId,
    this.electrodomesticoId,
    this.pasoActual = 0,
    this.estado = EstadoProgresoLeccion.enCurso,
    this.createdAt,
    this.completedAt,
  });

  final String id;
  final String leccionId;
  final String? electrodomesticoId;
  final int pasoActual;
  final EstadoProgresoLeccion estado;
  final DateTime? createdAt;
  final DateTime? completedAt;

  factory ProgresoLeccion.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ProgresoLeccion(
      id: doc.id,
      leccionId: data['leccionId'] as String? ?? '',
      electrodomesticoId: data['electrodomesticoId'] as String?,
      pasoActual: (data['pasoActual'] as num?)?.toInt() ?? 0,
      estado: EstadoProgresoLeccion.values.firstWhere((e) => e.name == data['estado'], orElse: () => EstadoProgresoLeccion.enCurso),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'leccionId': leccionId,
        if (electrodomesticoId != null) 'electrodomesticoId': electrodomesticoId,
        'pasoActual': pasoActual,
        'estado': estado.name,
      };
}
