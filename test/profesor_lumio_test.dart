import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lumio/theme/design_tokens.dart';
import 'package:lumio/widgets/profesor_lumio.dart';

Widget _envolver(Widget child) => MaterialApp(theme: buildLumioLightTheme(), home: Scaffold(body: child));

void main() {
  for (final pose in PoseProfesor.values) {
    testWidgets('se renderiza con la pose $pose y el mensaje dado', (tester) async {
      await tester.pumpWidget(_envolver(ProfesorLumio(pose: pose, mensaje: 'Mensaje de prueba')));
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Mensaje de prueba'), findsOneWidget);
    });
  }
}
