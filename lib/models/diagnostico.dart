// lib/models/diagnostico.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoDiagnostico {
  investigando,
  resuelto,
  necesitaMasInfo,
  escaladoProfesional,
  noUsarHastaRevisar;

  static EstadoDiagnostico parse(String? v) => EstadoDiagnostico.values.firstWhere((e) => e.name == v, orElse: () => EstadoDiagnostico.investigando);

  String get etiqueta => switch (this) {
        EstadoDiagnostico.investigando => 'Investigando',
        EstadoDiagnostico.resuelto => 'Resuelto',
        EstadoDiagnostico.necesitaMasInfo => 'Necesita más información',
        EstadoDiagnostico.escaladoProfesional => 'Requiere un profesional',
        EstadoDiagnostico.noUsarHastaRevisar => 'No usar hasta revisar',
      };
}

class MensajeDiagnostico {
  const MensajeDiagnostico({required this.id, required this.rol, required this.contenido, this.esAvisoSeguridad = false, this.createdAt});

  final String id;
  final String rol; // user | assistant
  final String contenido;
  final bool esAvisoSeguridad;
  final DateTime? createdAt;

  factory MensajeDiagnostico.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return MensajeDiagnostico(
      id: doc.id,
      rol: data['rol'] as String? ?? 'assistant',
      contenido: data['contenido'] as String? ?? '',
      esAvisoSeguridad: data['esAvisoSeguridad'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class SesionDiagnostico {
  const SesionDiagnostico({
    required this.id,
    this.electrodomesticoId,
    required this.sintoma,
    this.estado = EstadoDiagnostico.investigando,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? electrodomesticoId;
  final String sintoma;
  final EstadoDiagnostico estado;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory SesionDiagnostico.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return SesionDiagnostico(
      id: doc.id,
      electrodomesticoId: data['electrodomesticoId'] as String?,
      sintoma: data['sintoma'] as String? ?? '',
      estado: EstadoDiagnostico.parse(data['estado'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
