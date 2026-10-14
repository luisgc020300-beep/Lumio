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
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.explicacion,
        titulo: '¿Cómo funciona por dentro?',
        cuerpo: 'La lavadora mezcla agua y detergente, calienta el agua si el programa lo pide, hace girar el tambor para mover la ropa, y al final expulsa el agua sucia (el "centrifugado" la seca parcialmente girando muy rápido).',
      ),
      PasoLeccion(
        tipo: TipoPasoLeccion.comprobacion,
        titulo: 'Comprueba lo que has aprendido',
        cuerpo: '¿Para qué sirve el filtro? Atrapa pelusa y objetos pequeños que se sueltan de la ropa durante el lavado, para que no lleguen a la bomba de desagüe.',
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
