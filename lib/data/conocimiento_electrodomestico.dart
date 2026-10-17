// lib/data/conocimiento_electrodomestico.dart

/// Porcentaje de "cuánto sabes" sobre un electrodoméstico -- determinista,
/// sin IA. Mide sobre todo conocimiento de la CATEGORÍA (el progreso de
/// lección es por leccionId, no por aparato físico, ver
/// LeccionService.obtenerProgreso), reforzado por problemas resueltos
/// específicamente con este aparato.
///
/// Peso 80 para lecciones completadas de la categoría, peso 20 para
/// problemas resueltos (saturando en 3: resolver 3 o más da el bono
/// completo, cada uno cuenta proporcionalmente antes de eso).
int calcularPorcentajeConocimiento({
  required int leccionesCompletadas,
  required int leccionesTotal,
  required int problemasResueltos,
}) {
  if (leccionesTotal <= 0) return 0;

  final pctLecciones = (leccionesCompletadas / leccionesTotal).clamp(0, 1);
  final pctProblemas = (problemasResueltos / 3).clamp(0, 1);

  return (pctLecciones * 80 + pctProblemas * 20).round().clamp(0, 100);
}
