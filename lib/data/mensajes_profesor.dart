// lib/data/mensajes_profesor.dart
//
// Mensajes fijos y revisados del profesor virtual -- NO hay generación
// por IA ni conversación real aquí: son frases ancladas al estado del
// alumno (antes de responder / acierto / fallo / cierre de lección), no
// al tema concreto de cada lección, para no tener que inventar contenido
// educativo nuevo sin revisar por cada una de las lecciones del catálogo.
// La rotación es determinista (por el id de la lección) solo para que no
// se repita literalmente la misma frase en todas las pantallas.

const _pistasComprobacion = [
  'Piénsalo con calma, no hay prisa.',
  'Fíjate bien en lo que acabas de leer.',
  'Elige la opción que mejor encaje con lo que has aprendido.',
];

const _feedbackCorrecto = [
  '¡Eso es! Lo has entendido.',
  '¡Exacto! Vas muy bien.',
];

const _feedbackIncorrecto = [
  'Casi. Mira la explicación y prueba otra vez.',
  'No es esa -- fíjate en la pista y vuelve a intentarlo.',
];

const _cierresLeccion = [
  '¡Lección completada! Cada vez entiendes mejor tu casa.',
  '¡Así se hace! Un aparato menos que te resulte misterioso.',
];

String _rotar(List<String> opciones, String semilla) => opciones[semilla.hashCode.abs() % opciones.length];

String saludoLeccion(String tituloLeccion) => '¡Vamos a por "$tituloLeccion"!';

String pistaComprobacion(String leccionId) => _rotar(_pistasComprobacion, leccionId);

String feedbackCorrecto(String leccionId) => _rotar(_feedbackCorrecto, '$leccionId-ok');

String feedbackIncorrecto(String leccionId) => _rotar(_feedbackIncorrecto, '$leccionId-fail');

String cierreLeccion(String leccionId) => _rotar(_cierresLeccion, leccionId);

const String saludoHome = 'Dime qué aparato de casa quieres entender hoy.';
