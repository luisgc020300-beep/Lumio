// Tests del flujo de lecciones -- sin tocar Firestore en ningún caso: solo
// se monta LeccionScreen y se interactúa con el quiz, nunca se pulsa
// "Siguiente"/"Terminar" (eso es lo único que llama a LeccionService, que
// necesita Firebase inicializado, fuera de alcance de un test de widgets
// puro -- mismo criterio que test/widget_test.dart).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lumio/data/catalogo_lecciones.dart';
import 'package:lumio/models/electrodomestico.dart';
import 'package:lumio/models/leccion.dart';
import 'package:lumio/screens/leccion_screen.dart';
import 'package:lumio/theme/design_tokens.dart';

Widget _envolver(Widget child) => MaterialApp(theme: buildLumioLightTheme(), home: child);

FilledButton _botonPrincipal(WidgetTester tester) => tester.widget<FilledButton>(find.byType(FilledButton));

void main() {
  group('catálogo', () {
    test('lavadora_entender tiene 5 pasos y una comprobación interactiva válida', () {
      final leccion = catalogoLecciones.firstWhere((l) => l.id == 'lavadora_entender');
      expect(leccion.pasos.length, 5);

      final comprobacion = leccion.pasos.firstWhere((p) => p.tipo == TipoPasoLeccion.comprobacion);
      expect(comprobacion.opciones, isNotNull);
      expect(comprobacion.opciones!.length, greaterThanOrEqualTo(2));
      expect(comprobacion.respuestaCorrecta, isNotNull);
      expect(comprobacion.respuestaCorrecta!, inInclusiveRange(0, comprobacion.opciones!.length - 1));
    });
  });

  group('LeccionScreen -- ilustración', () {
    testWidgets('un paso con imagenAsset configurado representa una imagen', (tester) async {
      const leccion = Leccion(
        id: 'test',
        titulo: 'Lección de prueba',
        categoria: CategoriaElectrodomestico.lavadoraSecadora,
        objetivo: 'Probar la ilustración',
        nivel: 'principiante',
        pasos: [
          PasoLeccion(tipo: TipoPasoLeccion.visual, titulo: 'Con imagen', cuerpo: 'Cuerpo.', imagenAsset: 'assets/lecciones/lavadora_entender/partes.webp'),
        ],
      );

      await tester.pumpWidget(_envolver(const LeccionScreen(leccion: leccion, progresoId: 'test')));
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('un paso sin imagenAsset no representa ninguna imagen ni deja hueco', (tester) async {
      const leccion = Leccion(
        id: 'test',
        titulo: 'Lección de prueba',
        categoria: CategoriaElectrodomestico.lavadoraSecadora,
        objetivo: 'Probar ausencia de ilustración',
        nivel: 'principiante',
        pasos: [
          PasoLeccion(tipo: TipoPasoLeccion.explicacion, titulo: 'Sin imagen', cuerpo: 'Cuerpo.'),
        ],
      );

      await tester.pumpWidget(_envolver(const LeccionScreen(leccion: leccion, progresoId: 'test')));
      await tester.pump();

      expect(find.byType(Image), findsNothing);
    });
  });

  group('LeccionScreen -- comprobación interactiva', () {
    const leccion = Leccion(
      id: 'test',
      titulo: 'Lección de prueba',
      categoria: CategoriaElectrodomestico.lavadoraSecadora,
      objetivo: 'Probar el quiz',
      nivel: 'principiante',
      pasos: [
        PasoLeccion(
          tipo: TipoPasoLeccion.comprobacion,
          titulo: 'Comprueba',
          cuerpo: '¿Cuál es la correcta?',
          opciones: ['Incorrecta A', 'Correcta', 'Incorrecta B'],
          respuestaCorrecta: 1,
          porQueImporta: 'Explicación de la respuesta correcta.',
        ),
        PasoLeccion(tipo: TipoPasoLeccion.resumen, titulo: 'Resumen', cuerpo: 'Fin.'),
      ],
    );

    testWidgets('sin selección, las 3 opciones se muestran y "Siguiente" está deshabilitado', (tester) async {
      await tester.pumpWidget(_envolver(const LeccionScreen(leccion: leccion, progresoId: 'test')));
      await tester.pump();

      expect(find.text('Incorrecta A'), findsOneWidget);
      expect(find.text('Correcta'), findsOneWidget);
      expect(find.text('Incorrecta B'), findsOneWidget);
      expect(_botonPrincipal(tester).onPressed, isNull);
    });

    testWidgets('seleccionar la opción incorrecta muestra feedback de error y habilita "Siguiente"', (tester) async {
      await tester.pumpWidget(_envolver(const LeccionScreen(leccion: leccion, progresoId: 'test')));
      await tester.pump();

      await tester.tap(find.text('Incorrecta A'));
      await tester.pump();

      // Aparece dos veces a propósito: una vez junto a la opción marcada
      // como incorrecta y otra en el banner de feedback.
      expect(find.byIcon(Icons.cancel_outlined), findsWidgets);
      expect(_botonPrincipal(tester).onPressed, isNotNull);
    });

    testWidgets('seleccionar la opción correcta muestra feedback de éxito y la explicación', (tester) async {
      await tester.pumpWidget(_envolver(const LeccionScreen(leccion: leccion, progresoId: 'test')));
      await tester.pump();

      await tester.tap(find.text('Correcta'));
      await tester.pump();

      // Aparece dos veces a propósito: una vez junto a la opción correcta
      // y otra en el banner de feedback.
      expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
      expect(find.text('Explicación de la respuesta correcta.'), findsOneWidget);
      expect(_botonPrincipal(tester).onPressed, isNotNull);
    });

    testWidgets('tras responder mal, se puede corregir seleccionando otra opción', (tester) async {
      await tester.pumpWidget(_envolver(const LeccionScreen(leccion: leccion, progresoId: 'test')));
      await tester.pump();

      await tester.tap(find.text('Incorrecta B'));
      await tester.pump();
      expect(find.byIcon(Icons.cancel_outlined), findsWidgets);

      await tester.tap(find.text('Correcta'));
      await tester.pump();
      expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
      expect(find.byIcon(Icons.cancel_outlined), findsNothing);
    });
  });
}
