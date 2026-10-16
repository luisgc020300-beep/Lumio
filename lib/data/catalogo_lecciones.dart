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
    palabrasClave: ['lavadora', 'lavarropas'],
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
    palabrasClave: ['lavadora', 'lavarropas', 'programa de lavado'],
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
        cuerpo: '¿Qué programa es más adecuado para una camiseta con un estampado delicado?',
        opciones: ['Algodón 40°C', 'Ropa delicada', 'El programa más largo que tenga la lavadora', 'Cualquiera, da igual'],
        respuestaCorrecta: 1,
        porQueImporta: 'El programa delicado usa agua más fría y un movimiento más suave del tambor, para no dañar el estampado ni la tela.',
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
    palabrasClave: ['frigorifico', 'nevera', 'refrigerador', 'frigo'],
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
        cuerpo: '¿Por qué no conviene guardar la leche o los huevos en los huecos de la puerta?',
        opciones: ['Porque no caben bien', 'Porque es la zona más cálida y con más variación de temperatura', 'Porque ahí hace más frío que en el resto', 'Da igual, es solo cuestión de espacio'],
        respuestaCorrecta: 1,
        porQueImporta: 'La puerta se abre constantemente, así que es la zona menos estable en temperatura -- mejor para salsas o bebidas que no necesiten tanto frío constante.',
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
    palabrasClave: ['horno'],
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
        cuerpo: 'Si una receta tradicional pide 200°C y vas a cocinarla en modo aire/ventilador, ¿qué deberías hacer con la temperatura?',
        opciones: ['Subirla unos 15-20°C', 'Bajarla unos 15-20°C', 'Dejarla igual', 'Duplicarla'],
        respuestaCorrecta: 1,
        porQueImporta: 'El aire en movimiento cocina de forma más eficiente, así que si no bajas la temperatura es fácil que algo se queme por fuera.',
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
    palabrasClave: ['aire acondicionado', 'climatizador', 'ac'],
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
        cuerpo: 'Si notas que el aire acondicionado enfría menos que antes, ¿qué deberías revisar primero?',
        opciones: ['El filtro, por si está sucio', 'El mando a distancia', 'La unidad exterior al completo', 'El color de la luz indicadora'],
        respuestaCorrecta: 0,
        porQueImporta: 'Un filtro sucio es la causa más habitual de que un aire acondicionado "enfríe poco" sin estar realmente averiado.',
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
    palabrasClave: ['tostadora', 'batidora', 'cafetera', 'hervidor'],
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
        cuerpo: '¿Por qué no debes sumergir la base de una batidora en agua, aunque sí puedas lavar el vaso?',
        opciones: ['Porque se puede oxidar el plástico', 'Porque la base contiene el motor y las conexiones eléctricas', 'Porque pierde la garantía', 'No hay ningún problema en hacerlo'],
        respuestaCorrecta: 1,
        porQueImporta: 'Mojar el motor o las conexiones eléctricas puede estropear el aparato o ser peligroso -- solo las partes extraíbles (vaso, cuchillas) suelen poder lavarse con agua.',
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
    palabrasClave: ['lavavajillas', 'lavaplatos'],
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
        cuerpo: '¿Qué pasa si no rellenas el depósito de abrillantador?',
        opciones: ['El lavavajillas no se enciende', 'La vajilla puede secar con gotas o marcas de agua visibles', 'El detergente deja de funcionar', 'No pasa nada, no influye en el resultado'],
        respuestaCorrecta: 1,
        porQueImporta: 'El abrillantador ayuda a que el agua se escurra bien de la vajilla en vez de quedarse en gotas -- sin él, puede quedar limpia pero con marcas.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.resumen,
        titulo: 'Resumen',
        cuerpo: 'Ya conoces las tres partes clave que mantienen tu lavavajillas funcionando bien.',
      ),
    ],
  ),
  const Leccion(
    id: 'radiador_entender',
    titulo: 'Entiende tu radiador',
    categoria: CategoriaElectrodomestico.radiador,
    objetivo: 'Saber cómo reparte el calor un radiador y qué hace cada parte básica.',
    nivel: 'principiante',
    palabrasClave: ['radiador', 'calefaccion', 'termostato'],
    pasos: [
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: '¿Qué vas a aprender?',
        cuerpo: 'Vas a entender para qué sirve un radiador, cómo reparte el calor por la habitación y qué controla la válvula que suele tener en la base.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.visual,
        titulo: 'Las partes principales',
        cuerpo: 'La válvula (normalmente en la parte de abajo) controla cuánta agua caliente entra -- es lo que regulas para que caliente más o menos. El purgador, en la parte de arriba, sirve para sacar el aire que se acumula dentro y que hace que el radiador caliente peor por zonas.',
        porQueImporta: 'Si notas que el radiador calienta frío por arriba y caliente por abajo, casi siempre es aire dentro -- y el purgador es justo lo que soluciona eso.',
        imagenAsset: 'assets/lecciones/radiador_entender/partes.webp',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: 'Agua caliente o eléctrico',
        cuerpo: 'Un radiador de agua caliente recibe el agua ya calentada por una caldera central y la hace circular por su interior. Un radiador eléctrico, en cambio, calienta él mismo una resistencia interna con electricidad -- no necesita caldera ni tuberías de agua, pero suele salir más caro de usar que uno conectado a una caldera de gas.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: 'Uso seguro',
        cuerpo: 'No seques ropa directamente encima de un radiador encendido mucho tiempo: reduce el calor que llega a la habitación y en modelos eléctricos puede ser un riesgo. Si notas una fuga de agua, apaga la calefacción y deja que se enfríe antes de tocar nada -- el agua caliente puede quemar.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.comprobacion,
        titulo: 'Comprueba lo que has aprendido',
        cuerpo: 'Tu radiador calienta frío por arriba pero caliente por abajo. ¿Qué es lo más probable?',
        opciones: [
          'Que tiene aire dentro y conviene purgarlo',
          'Que está estropeado y hay que cambiarlo',
          'Que la válvula está mal instalada',
          'Es normal, todos los radiadores funcionan así',
        ],
        respuestaCorrecta: 0,
        porQueImporta: 'El aire acumulado sube a la parte de arriba e impide que el agua caliente llegue bien -- purgarlo (soltar ese aire con la llave del purgador) suele arreglarlo.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.resumen,
        titulo: 'Resumen',
        cuerpo: 'Ya conoces la válvula y el purgador, la diferencia entre agua caliente y eléctrico, y qué hacer con seguridad ante una fuga.',
      ),
    ],
  ),
  const Leccion(
    id: 'grifo_entender',
    titulo: 'Entiende tu grifo',
    categoria: CategoriaElectrodomestico.grifo,
    objetivo: 'Saber cómo regula el agua un grifo y cómo detectar un problema a tiempo.',
    nivel: 'principiante',
    palabrasClave: ['grifo', 'llave de paso', 'griferia'],
    pasos: [
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: '¿Qué vas a aprender?',
        cuerpo: 'Vas a entender cómo un grifo controla el paso del agua, qué tipos de mecanismo son los más habituales en una casa, y cómo detectar un problema sin necesidad de repararlo tú mismo.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.visual,
        titulo: 'Cómo abre y cierra el paso del agua',
        cuerpo: 'Dentro del grifo hay una pieza (un cartucho o una válvula, según el modelo) que, al mover el mando, deja pasar más o menos agua. Al cerrarlo del todo, esa pieza bloquea el paso y el agua deja de salir; al abrirlo, libera el paso y el agua fluye.',
        porQueImporta: 'Cuando un grifo gotea incluso cerrado del todo, normalmente es esa pieza interior la que ya no sella bien -- no la tubería.',
        imagenAsset: 'assets/lecciones/grifo_entender/mecanismo.webp',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: 'Monomando o de dos llaves',
        cuerpo: 'Un grifo monomando regula con una sola palanca tanto la cantidad de agua como la temperatura (moviéndola a un lado u otro). Uno de dos llaves tiene un mando separado para el agua fría y otro para la caliente, y mezclas tú mismo moviendo ambos.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: 'Ahorro y señales de aviso',
        cuerpo: 'Cerrar el grifo mientras enjabonas o cepillas los dientes ahorra bastante agua a lo largo del día. Si ves una gota constante incluso cerrado, o notas que el agua sale más floja que antes, son señales de que conviene revisarlo -- no intentes desmontarlo si no sabes cómo, mejor avisa a un profesional o cierra la llave de paso si hay una fuga importante.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.comprobacion,
        titulo: 'Comprueba lo que has aprendido',
        cuerpo: 'Tu grifo gotea aunque lo cierres del todo. ¿Cuál es la causa más probable?',
        opciones: [
          'La tubería del edificio está rota',
          'La pieza interior (cartucho o válvula) ya no sella bien',
          'El agua del grifo está contaminada',
          'Es normal en todos los grifos y no indica nada',
        ],
        respuestaCorrecta: 1,
        porQueImporta: 'Esa pieza es la que bloquea el paso del agua al cerrar -- cuando se desgasta, deja pasar un goteo aunque el mando esté cerrado del todo.',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.resumen,
        titulo: 'Resumen',
        cuerpo: 'Ya sabes cómo un grifo controla el agua por dentro, la diferencia entre monomando y dos llaves, y qué señales indican que conviene revisarlo.',
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
