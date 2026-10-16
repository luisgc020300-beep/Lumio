// Pruebas de normalización y sinónimos de la búsqueda de Explorar --
// contra el catálogo real, para que confirmen de verdad lo que un usuario
// ve, no un catálogo de prueba artificial.
import 'package:flutter_test/flutter_test.dart';

import 'package:lumio/data/busqueda_lecciones.dart';
import 'package:lumio/data/catalogo_lecciones.dart';

bool _hayResultadoPara(String busqueda) {
  final normalizada = normalizarBusqueda(busqueda);
  return catalogoLecciones.any((l) => leccionCoincideConBusqueda(l, normalizada));
}

void main() {
  group('normalizarBusqueda', () {
    test('minúsculas y mayúsculas son equivalentes', () {
      expect(normalizarBusqueda('RADIADOR'), normalizarBusqueda('radiador'));
    });

    test('quita acentos y la ñ', () {
      expect(normalizarBusqueda('frigorífico'), 'frigorifico');
      expect(normalizarBusqueda('Niño'), 'nino');
    });
  });

  group('búsquedas con resultado -- términos exactos pedidos', () {
    for (final termino in ['lavadora', 'frigorífico', 'nevera', 'refrigerador', 'lavavajillas', 'radiador', 'grifo', 'aire acondicionado', 'horno']) {
      test('"$termino" encuentra al menos una lección', () {
        expect(_hayResultadoPara(termino), isTrue, reason: 'se esperaba encontrar una lección para "$termino"');
      });
    }

    test('variantes sin acento y en mayúsculas también encuentran resultado', () {
      expect(_hayResultadoPara('FRIGORIFICO'), isTrue);
      expect(_hayResultadoPara('Radiador'), isTrue);
      expect(_hayResultadoPara('GRIFO'), isTrue);
    });
  });

  group('búsquedas sin resultado -- honesto, no inventa contenido', () {
    for (final termino in ['microondas', 'aspiradora']) {
      test('"$termino" no devuelve ninguna lección todavía', () {
        expect(_hayResultadoPara(termino), isFalse, reason: 'no existe lección de "$termino" en el catálogo -- si esto falla, hay que revisar que no se esté inventando una coincidencia');
      });
    }
  });

  group('leccionCoincideConBusqueda', () {
    test('una búsqueda vacía coincide con cualquier lección (sin filtro)', () {
      final leccion = catalogoLecciones.first;
      expect(leccionCoincideConBusqueda(leccion, ''), isTrue);
    });

    test('coincide por palabra clave aunque el título no la contenga', () {
      final frigorifico = catalogoLecciones.firstWhere((l) => l.id == 'frigorifico_entender');
      expect(frigorifico.titulo.toLowerCase().contains('nevera'), isFalse);
      expect(leccionCoincideConBusqueda(frigorifico, normalizarBusqueda('nevera')), isTrue);
    });
  });
}
