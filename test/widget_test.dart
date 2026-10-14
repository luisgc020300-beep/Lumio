// Smoke test: construir los temas de Lumio no debe lanzar excepciones.
// No se monta LumioApp completa porque StreamBuilder sobre
// FirebaseAuth.instance.authStateChanges() necesita Firebase inicializado,
// fuera de alcance de un test de widgets puro (mismo criterio que Vence).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lumio/theme/design_tokens.dart';

void main() {
  testWidgets('los temas claro y oscuro de Lumio se construyen sin errores', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildLumioLightTheme(),
      darkTheme: buildLumioDarkTheme(),
      home: Builder(builder: (context) {
        final colors = Theme.of(context).extension<LumioColors>();
        expect(colors, isNotNull);
        return Scaffold(body: Text('Lumio', style: Theme.of(context).textTheme.displayMedium));
      }),
    ));

    expect(find.text('Lumio'), findsOneWidget);
  });
}
