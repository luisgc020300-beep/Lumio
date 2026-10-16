// lib/data/catalogo_lecciones.dart
//
// Catálogo curado de lecciones -- contenido real escrito a mano, NO
// generado por IA en el momento (el brief es explícito: nunca rellenar la
// biblioteca con contenido falso para "parecer poblada"). Empieza
// pequeño y crece con revisión editorial, no generación automática.
import '../models/electrodomestico.dart';
import '../models/leccion.dart';

final List<Leccion> catalogoLecciones = [
  const Leccion(
    id: 'lavadora_entender',
    titulo: 'Entiende tu lavadora',
    categoria: CategoriaElectrodomestico.lavadoraSecadora,
    objetivo: 'Reconocer las partes principales y para qué sirve cada una.',
    nivel: 'principiante',
    pasos: [
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: '¿Qué vas a aprender?',
        cuerpo: 'En esta lección vas a reconocer las partes principales de una lavadora y entender, a grandes rasgos, qué hace cada una.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.visual,
        titulo: 'Las partes principales',
        cuerpo: 'El cajetín de detergente añade el jabón y suavizante en el momento adecuado del ciclo. El tambor es donde va la ropa. El filtro atrapa pelusa y objetos pequeños, y hay que limpiarlo de vez en cuando.',
        porQueImporta: 'Saber dónde está cada parte te ayuda a usar la lavadora correctamente y a solucionar problemas simples sin ayuda.',
        imagenAsset: 'assets/lecciones/lavadora_entender/partes.webp',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: '¿Cómo funciona por dentro?',
        cuerpo: 'La lavadora mezcla agua y detergente, calienta el agua si el programa lo pide, hace girar el tambor para mover la ropa, y al final expulsa el agua sucia (el "centrifugado" la seca parcialmente girando muy rápido).',
        imagenAsset: 'assets/lecciones/lavadora_entender/ciclo.webp',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.comprobacion,
        titulo: 'Comprueba lo que has aprendido',
        cuerpo: '¿Para qué sirve el filtro?',
        opciones: [
          'Para que la ropa salga perfumada',
          'Atrapa pelusa y objetos pequeños para que no lleguen a la bomba de desagüe',
          'Calienta el agua antes del lavado',
          'Dosifica el detergente automáticamente',
        ],
        respuestaCorrecta: 1,
        porQueImporta: 'Por eso hay que limpiarlo de vez en cuando: si se atasca, el agua no desagua bien o la bomba puede dañarse.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.resumen,
        titulo: 'Resumen',
        cuerpo: 'Ya conoces el cajetín, el tambor y el filtro, y a grandes rasgos cómo funciona un ciclo de lavado.',
      ),
    ],
  ),
  const Leccion(
    id: 'lavadora_elegir_programa',
    titulo: 'Elige el programa de lavado adecuado',
    categoria: CategoriaElectrodomestico.lavadoraSecadora,
    objetivo: 'Saber qué programa usar según el tipo de ropa.',
    nivel: 'principiante',
    pasos: [
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: '¿Qué vas a aprender?',
        cuerpo: 'Vas a aprender a elegir entre los programas más habituales según lo que vayas a lavar.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: 'Algodón 40°C',
        cuerpo: 'Es el programa de uso diario para ropa normal: camisetas, ropa interior, toallas finas. Buen equilibrio entre limpieza y cuidado del tejido.',
        porQueImporta: 'Usarlo por defecto evita gastar más agua/energía de la necesaria en la ropa de cada día.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: 'Ropa delicada / 30°C',
        cuerpo: 'Para prendas delicadas (ropa con print, sujetadores, tejidos finos): agua más fría y movimiento más suave del tambor, para no dañar la tela.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.comprobacion,
        titulo: 'Comprueba lo que has aprendido',
        cuerpo: 'Para lavar toallas de uso diario, "Algodón 40°C" es una elección razonable; para una camiseta con un estampado delicado, mejor "Ropa delicada".',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.resumen,
        titulo: 'Resumen',
        cuerpo: 'Ya sabes diferenciar cuándo usar Algodón 40°C y cuándo un programa delicado.',
      ),
    ],
  ),
  const Leccion(
    id: 'frigorifico_entender',
    titulo: 'Entiende tu frigorífico',
    categoria: CategoriaElectrodomestico.frigorificoCongelador,
    objetivo: 'Reconocer sus zonas de temperatura y por qué importa dónde guardas cada alimento.',
    nivel: 'principiante',
    pasos: [
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: '¿Qué vas a aprender?',
        cuerpo: 'Vas a conocer las distintas zonas de temperatura de un frigorífico y por qué no da igual dónde coloques cada alimento.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.visual,
        titulo: 'Las zonas principales',
        cuerpo: 'La puerta es la zona más cálida y con más variación de temperatura, porque se abre constantemente. El cajón de verduras mantiene más humedad para que no se marchiten. El congelador es una zona aparte, de frío constante, pensada para conservación larga.',
        porQueImporta: 'Guardar cada alimento en la zona adecuada hace que dure más y reduce el desperdicio de comida.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: '¿Cómo funciona por dentro?',
        cuerpo: 'Un frigorífico no "genera frío": mueve el calor de dentro hacia fuera mediante un gas refrigerante que circula por un circuito, con la ayuda de un compresor. Es el mismo principio que usa el aire acondicionado.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.comprobacion,
        titulo: 'Comprueba lo que has aprendido',
        cuerpo: '¿Por qué no conviene guardar la leche o los huevos en los huecos de la puerta, aunque muchos frigoríficos los incluyan ahí? Porque es la zona más cálida y con más variación de temperatura del frigorífico.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.resumen,
        titulo: 'Resumen',
        cuerpo: 'Ya sabes que la puerta, el cajón de verduras y el congelador son zonas distintas, y por qué eso importa a la hora de guardar la compra.',
      ),
    ],
  ),
  const Leccion(
    id: 'horno_entender',
    titulo: 'Entiende tu horno',
    categoria: CategoriaElectrodomestico.hornoPlaca,
    objetivo: 'Reconocer los modos de cocción más habituales y cuándo usar cada uno.',
    nivel: 'principiante',
    pasos: [
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: '¿Qué vas a aprender?',
        cuerpo: 'Vas a conocer los modos de cocción más comunes de un horno y cuándo conviene usar cada uno.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.visual,
        titulo: 'Los modos principales',
        cuerpo: 'Calor arriba y abajo es el modo tradicional, bueno para asados y platos que necesitan dorarse por ambos lados. El grill solo calienta desde arriba con fuerza, ideal para gratinar. El modo aire o ventilador reparte el calor de forma uniforme con un ventilador, muy útil si cocinas en varias bandejas a la vez.',
        porQueImporta: 'Elegir el modo equivocado es una causa habitual de que algo se queme por fuera y quede crudo por dentro, o al revés.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: 'Un detalle que casi nadie tiene en cuenta',
        cuerpo: 'Si una receta está pensada para calor tradicional y usas el modo aire/ventilador, conviene bajar la temperatura unos 15-20°C respecto a lo que indica la receta, porque el aire en movimiento cocina de forma más eficiente.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.comprobacion,
        titulo: 'Comprueba lo que has aprendido',
        cuerpo: 'Si una receta tradicional pide 200°C y vas a usar el modo aire/ventilador, ¿subes o bajas la temperatura? La bajas, normalmente unos 15-20°C.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.resumen,
        titulo: 'Resumen',
        cuerpo: 'Ya distingues calor tradicional, grill y aire/ventilador, y sabes ajustar la temperatura al cambiar de modo.',
      ),
    ],
  ),
  const Leccion(
    id: 'aire_acondicionado_entender',
    titulo: 'Entiende tu aire acondicionado',
    categoria: CategoriaElectrodomestico.aireAcondicionado,
    objetivo: 'Reconocer sus modos básicos y por qué el filtro es la pieza que más cuidado necesita.',
    nivel: 'principiante',
    pasos: [
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: '¿Qué vas a aprender?',
        cuerpo: 'Vas a conocer los modos básicos de un aire acondicionado y por qué el filtro es la parte que más afecta a que funcione bien.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.visual,
        titulo: 'Las partes principales',
        cuerpo: 'El filtro de aire atrapa polvo antes de que entre en la unidad -- si se ensucia, el aparato enfría peor y gasta más. La unidad exterior es la que expulsa el calor que saca de la habitación cuando enfría. El mando suele incluir, además de frío, los modos calor, deshumidificar y solo ventilador.',
        porQueImporta: 'Un filtro sucio es la causa más habitual de que un aire acondicionado "enfríe poco" sin que el aparato esté realmente averiado.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: '¿Cómo funciona por dentro?',
        cuerpo: 'En modo frío, el aire acondicionado funciona igual que un frigorífico: mueve el calor de dentro de la habitación hacia fuera mediante un gas refrigerante, en vez de "crear" frío de la nada.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.comprobacion,
        titulo: 'Comprueba lo que has aprendido',
        cuerpo: 'Si notas que el aire enfría menos que antes, ¿qué es lo primero que deberías revisar? El filtro, por si está sucio.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.resumen,
        titulo: 'Resumen',
        cuerpo: 'Ya conoces los modos básicos y sabes que un filtro limpio es clave para que el aparato rinda bien.',
      ),
    ],
  ),
  const Leccion(
    id: 'pequenos_electrodomesticos_cuidado',
    titulo: 'Cuida tus pequeños electrodomésticos',
    categoria: CategoriaElectrodomestico.pequenoElectrodomestico,
    objetivo: 'Conocer buenas prácticas generales de limpieza y cuidado que alargan su vida útil.',
    nivel: 'principiante',
    pasos: [
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: '¿Qué vas a aprender?',
        cuerpo: 'Tostadoras, batidoras, cafeteras... son aparatos distintos, pero comparten unas pocas normas de cuidado que evitan la mayoría de averías prematuras.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.visual,
        titulo: 'La regla más importante',
        cuerpo: 'Desenchufa siempre el aparato antes de limpiarlo, y nunca sumerjas en agua la base donde está el motor o las conexiones eléctricas -- solo las partes extraíbles (jarra, cuchillas, filtros) suelen poder lavarse con agua.',
        porQueImporta: 'Es la causa más común de que un pequeño electrodoméstico se estropee antes de tiempo, o incluso de que sea peligroso seguir usándolo.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: 'La cal, la gran enemiga silenciosa',
        cuerpo: 'En cafeteras y hervidores, la cal del agua se va acumulando por dentro con el uso. Un ciclo de descalcificación de vez en cuando (agua con vinagre o un producto específico) evita que pierdan rendimiento o se averíen antes de tiempo.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.comprobacion,
        titulo: 'Comprueba lo que has aprendido',
        cuerpo: '¿Por qué no debes sumergir la base de una batidora en agua, aunque sí puedas lavar el vaso? Porque la base contiene el motor y las conexiones eléctricas.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.resumen,
        titulo: 'Resumen',
        cuerpo: 'Ya conoces las dos normas que más alargan la vida de cualquier pequeño electrodoméstico: cuidado con el agua en las partes eléctricas, y descalcificación regular si usan agua.',
      ),
    ],
  ),
  const Leccion(
    id: 'lavavajillas_entender',
    titulo: 'Entiende tu lavavajillas',
    categoria: CategoriaElectrodomestico.lavavajillas,
    objetivo: 'Reconocer sus partes principales y su ciclo básico.',
    nivel: 'principiante',
    pasos: [
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: '¿Qué vas a aprender?',
        cuerpo: 'Vas a conocer el depósito de sal, el abrillantador y el dosificador de detergente, y para qué sirve cada uno.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.visual,
        titulo: 'Las partes principales',
        cuerpo: 'El dosificador de detergente libera el jabón en el momento correcto. El depósito de abrillantador ayuda a que la vajilla seque sin marcas. El depósito de sal (si tu lavavajillas lo tiene) ablanda el agua para que el detergente funcione mejor.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.comprobacion,
        titulo: 'Comprueba lo que has aprendido',
        cuerpo: '¿Qué pasa si no rellenas el abrillantador? La vajilla puede secar con gotas o marcas de agua visibles, aunque quede limpia.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.resumen,
        titulo: 'Resumen',
        cuerpo: 'Ya conoces las tres partes clave que mantienen tu lavavajillas funcionando bien.',
      ),
    ],
  ),
];

List<Leccion> leccionesPorCategoria(CategoriaElectrodomestico c) => catalogoLecciones.where((l) => l.categoria == c).toList();

Leccion? leccionPorId(String id) {
  for (final l in catalogoLecciones) {
    if (l.id == id) return l;
  }
  return null;
}
