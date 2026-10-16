// lib/widgets/profesor_lumio.dart
import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

enum PoseProfesor { saludo, celebrando, animando }

extension on PoseProfesor {
  String get asset => switch (this) {
        PoseProfesor.saludo => 'assets/profesor/saludo.webp',
        PoseProfesor.celebrando => 'assets/profesor/celebrando.webp',
        PoseProfesor.animando => 'assets/profesor/animando.webp',
      };
}

/// El profesor virtual de Lumio -- un personaje 2D fijo (ilustración
/// estática por pose, nunca generada ni animada) con un mensaje
/// contextual revisado a su lado. Ver lib/data/mensajes_profesor.dart
/// para el origen de los mensajes.
class ProfesorLumio extends StatelessWidget {
  const ProfesorLumio({required this.pose, required this.mensaje, super.key});

  final PoseProfesor pose;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: mensaje,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Image.asset(pose.asset, width: 56, height: 56),
          ),
          const SizedBox(width: LumioSpace.s3),
          Expanded(
            child: ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: LumioSpace.s3, vertical: LumioSpace.s2),
                decoration: BoxDecoration(
                  color: context.colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(LumioRadius.sm),
                ),
                child: Text(mensaje, style: TextStyle(fontSize: 13.5, color: context.colors.ink, height: 1.3)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
