// lib/models/electrodomestico.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum CategoriaElectrodomestico {
  lavadoraSecadora,
  lavavajillas,
  frigorificoCongelador,
  hornoPlaca,
  aireAcondicionado,
  pequenoElectrodomestico,
  otro;

  String get valor => switch (this) {
        CategoriaElectrodomestico.lavadoraSecadora => 'lavadora_secadora',
        CategoriaElectrodomestico.frigorificoCongelador => 'frigorifico_congelador',
        CategoriaElectrodomestico.hornoPlaca => 'horno_placa',
        CategoriaElectrodomestico.aireAcondicionado => 'aire_acondicionado',
        CategoriaElectrodomestico.pequenoElectrodomestico => 'pequeno_electrodomestico',
        _ => name,
      };

  static CategoriaElectrodomestico parse(String? v) => CategoriaElectrodomestico.values.firstWhere((e) => e.valor == v, orElse: () => CategoriaElectrodomestico.otro);

  String get etiqueta => switch (this) {
        CategoriaElectrodomestico.lavadoraSecadora => 'Lavadoras y secadoras',
        CategoriaElectrodomestico.lavavajillas => 'Lavavajillas',
        CategoriaElectrodomestico.frigorificoCongelador => 'Frigoríficos y congeladores',
        CategoriaElectrodomestico.hornoPlaca => 'Hornos y placas',
        CategoriaElectrodomestico.aireAcondicionado => 'Aire acondicionado',
        CategoriaElectrodomestico.pequenoElectrodomestico => 'Pequeños electrodomésticos',
        CategoriaElectrodomestico.otro => 'Otros',
      };

  IconIdentificador get icono => switch (this) {
        CategoriaElectrodomestico.lavadoraSecadora => IconIdentificador.lavadora,
        CategoriaElectrodomestico.lavavajillas => IconIdentificador.lavavajillas,
        CategoriaElectrodomestico.frigorificoCongelador => IconIdentificador.frigorifico,
        CategoriaElectrodomestico.hornoPlaca => IconIdentificador.horno,
        CategoriaElectrodomestico.aireAcondicionado => IconIdentificador.aire,
        CategoriaElectrodomestico.pequenoElectrodomestico => IconIdentificador.pequeno,
        CategoriaElectrodomestico.otro => IconIdentificador.otro,
      };
}

/// Identificador neutro (no depende de Material Icons) para que el icono
/// real se resuelva en la capa de UI -- mantiene el modelo libre de
/// dependencias de Flutter.
enum IconIdentificador { lavadora, lavavajillas, frigorifico, horno, aire, pequeno, otro }

enum EstadoIdentificacion {
  sinIdentificar,
  identificadoGeneral, // categoría reconocida, sin modelo verificado
  identificadoConModelo; // marca + modelo verificados con evidencia suficiente

  static EstadoIdentificacion parse(String? v) => EstadoIdentificacion.values.firstWhere((e) => e.name == v, orElse: () => EstadoIdentificacion.sinIdentificar);
}

class Electrodomestico {
  const Electrodomestico({
    required this.id,
    required this.nombre,
    this.categoria = CategoriaElectrodomestico.otro,
    this.fabricante,
    this.modelo,
    this.estadoIdentificacion = EstadoIdentificacion.sinIdentificar,
    this.confianzaIdentificacion,
    this.fotoUrl,
    this.controlesVisibles = const [],
    this.incertidumbres = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String nombre;
  final CategoriaElectrodomestico categoria;
  final String? fabricante;
  final String? modelo;
  final EstadoIdentificacion estadoIdentificacion;
  final double? confianzaIdentificacion;
  final String? fotoUrl;
  final List<String> controlesVisibles;
  final List<String> incertidumbres;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get modeloVerificado => estadoIdentificacion == EstadoIdentificacion.identificadoConModelo;

  factory Electrodomestico.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Electrodomestico(
      id: doc.id,
      nombre: data['nombre'] as String? ?? '',
      categoria: CategoriaElectrodomestico.parse(data['categoria'] as String?),
      fabricante: data['fabricante'] as String?,
      modelo: data['modelo'] as String?,
      estadoIdentificacion: EstadoIdentificacion.parse(data['estadoIdentificacion'] as String?),
      confianzaIdentificacion: (data['confianzaIdentificacion'] as num?)?.toDouble(),
      fotoUrl: data['fotoUrl'] as String?,
      controlesVisibles: ((data['controlesVisibles'] as List?) ?? []).map((e) => e as String).toList(),
      incertidumbres: ((data['incertidumbres'] as List?) ?? []).map((e) => e as String).toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'categoria': categoria.valor,
        if (fabricante != null) 'fabricante': fabricante,
        if (modelo != null) 'modelo': modelo,
        'estadoIdentificacion': estadoIdentificacion.name,
        if (confianzaIdentificacion != null) 'confianzaIdentificacion': confianzaIdentificacion,
        if (fotoUrl != null) 'fotoUrl': fotoUrl,
        'controlesVisibles': controlesVisibles,
        'incertidumbres': incertidumbres,
      };
}
