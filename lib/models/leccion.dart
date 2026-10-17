// lib/models/leccion.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'electrodomestico.dart';

enum TipoPasoLeccion { explicacion, visual, tarea, comprobacion, resumen }

/// Una pregunta dentro de un paso de comprobación -- un paso puede tener
/// varias, para que fallar una no termine la comprobación: se repasa esa
/// pregunta al final, después de las demás (ver `_ComprobacionMultiple`
/// en lib/screens/leccion_screen.dart).
class PreguntaQuiz {
  const PreguntaQuiz({required this.pregunta, required this.opciones, required this.respuestaCorrecta, this.explicacion});

  final String pregunta;
  final List<String> opciones;
  final int respuestaCorrecta;
  final String? explicacion;
}

class PasoLeccion {
  const PasoLeccion({
    required this.tipo,
    required this.titulo,
    required this.cuerpo,
    this.imagenAsset,
    this.modelo3dAsset,
    this.porQueImporta,
    this.preguntas,
  });

  final TipoPasoLeccion tipo;
  final String titulo;
  final String cuerpo;
  /// Asset local empaquetado con la app (contenido curado, no generado) --
  /// nunca una foto real del aparato del usuario en lecciones de catálogo.
  final String? imagenAsset;
  /// Modelo 3D (.glb) interactivo -- cuando está presente, la pantalla de
  /// lección lo muestra en vez de [imagenAsset] para este paso (sigue
  /// contando como la ilustración 2D de catálogo a efectos de
  /// [Leccion.primeraIlustracion], que no sabe de modelos 3D).
  final String? modelo3dAsset;
  /// "Por qué importa" -- el principio central del producto: explicar el
  /// motivo, no solo el paso.
  final String? porQueImporta;
  /// Preguntas del quiz -- solo en pasos [TipoPasoLeccion.comprobacion]
  /// con comprobación interactiva real. Null en el resto.
  final List<PreguntaQuiz>? preguntas;
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
    this.palabrasClave = const [],
  });

  final String id;
  final String titulo;
  final CategoriaElectrodomestico categoria;
  final String objetivo;
  final String nivel; // principiante | con_base | avanzado
  final List<PasoLeccion> pasos;
  /// Sinónimos/variantes habituales del aparato (p. ej. "nevera",
  /// "refrigerador" para frigorífico) -- usado por la búsqueda de
  /// Explorar para que no dependa solo de que el título literal
  /// contenga la palabra buscada. Ver lib/data/busqueda_lecciones.dart.
  final List<String> palabrasClave;
  /// true si requiere un electrodoméstico concreto guardado (no aplica a
  /// lecciones generales de categoría).
  final bool applianceEspecifico;

  /// Primera ilustración de catálogo entre los pasos, si hay alguna --
  /// usado como miniatura en las listas de lecciones (Explorar, Inicio)
  /// en vez del icono genérico.
  String? get primeraIlustracion {
    for (final p in pasos) {
      if (p.imagenAsset != null) return p.imagenAsset;
    }
    return null;
  }
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
