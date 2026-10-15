// lib/theme/categoria_estilos.dart
import 'package:flutter/material.dart';

import '../models/electrodomestico.dart';
import 'design_tokens.dart';

IconData iconoCategoria(IconIdentificador i) => switch (i) {
      IconIdentificador.lavadora => Icons.local_laundry_service_outlined,
      IconIdentificador.lavavajillas => Icons.countertops_outlined,
      IconIdentificador.frigorifico => Icons.kitchen_outlined,
      IconIdentificador.horno => Icons.microwave_outlined,
      IconIdentificador.aire => Icons.ac_unit_outlined,
      IconIdentificador.pequeno => Icons.blender_outlined,
      IconIdentificador.otro => Icons.devices_other_outlined,
    };

/// Color de acento por categoría -- variedad visual entre tarjetas,
/// siempre a partir de los tokens de marca (nunca hex sueltos en pantallas).
Color colorCategoria(BuildContext context, CategoriaElectrodomestico categoria) {
  final c = context.colors;
  return switch (categoria) {
    CategoriaElectrodomestico.lavadoraSecadora => c.brand,
    CategoriaElectrodomestico.lavavajillas => c.success,
    CategoriaElectrodomestico.frigorificoCongelador => c.lavanda,
    CategoriaElectrodomestico.hornoPlaca => c.warning,
    CategoriaElectrodomestico.aireAcondicionado => c.accentCyan,
    CategoriaElectrodomestico.pequenoElectrodomestico => c.brandStrong,
    CategoriaElectrodomestico.otro => c.inkMuted,
  };
}
