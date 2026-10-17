// Validez de la fórmula pura de "cuánto sabes" -- Dart puro, sin widgets
// ni Firestore. Ver lib/data/conocimiento_electrodomestico.dart para los
// pesos (80 lecciones / 20 problemas, saturando en 3).
import 'package:flutter_test/flutter_test.dart';

import 'package:lumio/data/conocimiento_electrodomestico.dart';

void main() {
  test('sin lecciones en la categoría, el porcentaje es 0', () {
    expect(calcularPorcentajeConocimiento(leccionesCompletadas: 0, leccionesTotal: 0, problemasResueltos: 5), 0);
  });

  test('ninguna lección completada y ningún problema resuelto da 0%', () {
    expect(calcularPorcentajeConocimiento(leccionesCompletadas: 0, leccionesTotal: 5, problemasResueltos: 0), 0);
  });

  test('todas las lecciones completadas sin problemas resueltos da 80%', () {
    expect(calcularPorcentajeConocimiento(leccionesCompletadas: 5, leccionesTotal: 5, problemasResueltos: 0), 80);
  });

  test('todas las lecciones completadas y 3+ problemas resueltos da 100%', () {
    expect(calcularPorcentajeConocimiento(leccionesCompletadas: 5, leccionesTotal: 5, problemasResueltos: 3), 100);
    expect(calcularPorcentajeConocimiento(leccionesCompletadas: 5, leccionesTotal: 5, problemasResueltos: 10), 100);
  });

  test('el bono de problemas resueltos satura en 3 -- cada uno suma proporcionalmente antes de eso', () {
    final unProblema = calcularPorcentajeConocimiento(leccionesCompletadas: 0, leccionesTotal: 5, problemasResueltos: 1);
    final dosProblemas = calcularPorcentajeConocimiento(leccionesCompletadas: 0, leccionesTotal: 5, problemasResueltos: 2);
    final tresProblemas = calcularPorcentajeConocimiento(leccionesCompletadas: 0, leccionesTotal: 5, problemasResueltos: 3);

    expect(unProblema, 7); // 20 * (1/3) = 6.67 -> redondeado a 7
    expect(dosProblemas, 13); // 20 * (2/3) = 13.33 -> redondeado a 13
    expect(tresProblemas, 20);
  });

  test('2 de 5 lecciones y 1 problema resuelto da un porcentaje intermedio defendible', () {
    // 80*(2/5) + 20*(1/3) = 32 + 6.67 = 38.67 -> redondeado a 39
    expect(calcularPorcentajeConocimiento(leccionesCompletadas: 2, leccionesTotal: 5, problemasResueltos: 1), 39);
  });

  test('el porcentaje nunca supera 100 ni baja de 0', () {
    expect(calcularPorcentajeConocimiento(leccionesCompletadas: 5, leccionesTotal: 5, problemasResueltos: 100), 100);
    expect(calcularPorcentajeConocimiento(leccionesCompletadas: 0, leccionesTotal: 5, problemasResueltos: 0), 0);
  });
}
