// lib/data/busqueda_lecciones.dart
//
// Normalización y coincidencia de búsqueda para Explorar -- separado del
// widget para que sea una función pura, fácil de probar sin montar nada.
// El español solo tiene un puñado de diacríticos, así que una tabla de
// sustitución manual es más simple y mantenible que añadir una dependencia
// nueva solo para esto.
import '../models/leccion.dart';

const Map<String, String> _sustitucionesAcentos = {
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'ü': 'u',
  'ñ': 'n',
};

String normalizarBusqueda(String texto) {
  var resultado = texto.toLowerCase().trim();
  _sustitucionesAcentos.forEach((acento, plano) {
    resultado = resultado.replaceAll(acento, plano);
  });
  return resultado;
}

/// true si [leccion] es un resultado razonable para [busquedaNormalizada]
/// (ya pasada por [normalizarBusqueda]). Compara contra el título, la
/// etiqueta de categoría y las palabras clave de la lección -- cada una
/// normalizada igual, para que mayúsculas/acentos nunca sean la causa de
/// un "sin resultados" evitable.
bool leccionCoincideConBusqueda(Leccion leccion, String busquedaNormalizada) {
  if (busquedaNormalizada.isEmpty) return true;
  final campos = [leccion.titulo, leccion.categoria.etiqueta, ...leccion.palabrasClave];
  return campos.any((campo) => normalizarBusqueda(campo).contains(busquedaNormalizada));
}
