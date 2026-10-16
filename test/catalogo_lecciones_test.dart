// Validez estructural del catálogo -- corre en Dart puro (sin widgets ni
// Firestore): ids únicos, cada comprobación interactiva con una respuesta
// correcta válida, y que cada imagenAsset referenciado exista de verdad en
// disco (para que una ruta rota no se descubra solo al abrir la app).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:lumio/data/catalogo_lecciones.dart';
import 'package:lumio/models/leccion.dart';

void main() {
  test('todos los ids de lección son únicos', () {
    final ids = catalogoLecciones.map((l) => l.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('toda lección tiene al menos un paso y un objetivo no vacío', () {
    for (final l in catalogoLecciones) {
      expect(l.pasos, isNotEmpty, reason: 'lección "${l.id}" sin pasos');
      expect(l.objetivo.trim(), isNotEmpty, reason: 'lección "${l.id}" sin objetivo');
    }
  });

  test('todo paso de comprobación con opciones tiene una respuesta correcta válida', () {
    for (final l in catalogoLecciones) {
      for (final p in l.pasos.where((p) => p.tipo == TipoPasoLeccion.comprobacion)) {
        if (p.opciones == null) continue; // variante antigua de solo texto, todavía permitida
        expect(p.opciones!.length, greaterThanOrEqualTo(2), reason: '"${l.id}": menos de 2 opciones');
        expect(p.respuestaCorrecta, isNotNull, reason: '"${l.id}": opciones sin respuestaCorrecta');
        expect(p.respuestaCorrecta!, inInclusiveRange(0, p.opciones!.length - 1), reason: '"${l.id}": respuestaCorrecta fuera de rango');
      }
    }
  });

  test('todo imagenAsset referenciado existe de verdad en disco', () {
    for (final l in catalogoLecciones) {
      for (final p in l.pasos) {
        if (p.imagenAsset == null) continue;
        final existe = File(p.imagenAsset!).existsSync();
        expect(existe, isTrue, reason: '"${l.id}": asset roto -- ${p.imagenAsset} no existe');
      }
    }
  });

  test('radiador_entender y grifo_entender están en el catálogo y se pueden abrir', () {
    final radiador = leccionPorId('radiador_entender');
    final grifo = leccionPorId('grifo_entender');
    expect(radiador, isNotNull);
    expect(grifo, isNotNull);
    expect(radiador!.pasos.any((p) => p.tipo == TipoPasoLeccion.comprobacion && p.opciones != null), isTrue);
    expect(grifo!.pasos.any((p) => p.tipo == TipoPasoLeccion.comprobacion && p.opciones != null), isTrue);
    expect(radiador.pasos.any((p) => p.imagenAsset != null), isTrue);
    expect(grifo.pasos.any((p) => p.imagenAsset != null), isTrue);
  });

  test('las 9 lecciones del catálogo tienen al menos una ilustración (cobertura visual completa)', () {
    for (final l in catalogoLecciones) {
      expect(l.primeraIlustracion, isNotNull, reason: '"${l.id}" todavía no tiene ninguna ilustración');
    }
    expect(catalogoLecciones.length, 9);
  });

  test('primeraIlustracion devuelve el primer imagenAsset entre los pasos, en orden', () {
    final conDosImagenes = catalogoLecciones.firstWhere((l) => l.pasos.where((p) => p.imagenAsset != null).length >= 2);
    final primeraEsperada = conDosImagenes.pasos.firstWhere((p) => p.imagenAsset != null).imagenAsset;
    expect(conDosImagenes.primeraIlustracion, primeraEsperada);
  });
}
