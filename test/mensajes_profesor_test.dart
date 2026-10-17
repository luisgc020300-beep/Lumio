// Pruebas puras de los mensajes fijos del profesor virtual -- sin
// widgets, sin Firestore.
import 'package:flutter_test/flutter_test.dart';

import 'package:lumio/data/mensajes_profesor.dart';

void main() {
  test('saludoLeccion incluye el título de la lección', () {
    expect(saludoLeccion('Entiende tu lavadora'), contains('Entiende tu lavadora'));
  });

  test('las funciones de rotación nunca devuelven texto vacío', () {
    for (final id in ['lavadora_entender', 'radiador_entender', 'grifo_entender', 'id_cualquiera']) {
      expect(pistaComprobacion(id).trim(), isNotEmpty);
      expect(feedbackCorrecto(id).trim(), isNotEmpty);
      expect(feedbackIncorrecto(id).trim(), isNotEmpty);
      expect(cierreLeccion(id).trim(), isNotEmpty);
      expect(comentarioTransicion(id, 2).trim(), isNotEmpty);
    }
  });

  test('la rotación es determinista -- el mismo id siempre da el mismo mensaje', () {
    expect(pistaComprobacion('lavadora_entender'), pistaComprobacion('lavadora_entender'));
    expect(feedbackCorrecto('grifo_entender'), feedbackCorrecto('grifo_entender'));
    expect(comentarioTransicion('radiador_entender', 2), comentarioTransicion('radiador_entender', 2));
  });

  test('saludoHome no está vacío', () {
    expect(saludoHome.trim(), isNotEmpty);
  });
}
