const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const functionsV1 = require('firebase-functions/v1');
const admin = require('firebase-admin');

admin.initializeApp();

const _anthropicKey = defineSecret('ANTHROPIC_API_KEY');
const REGION = 'europe-west1';
const MODEL = 'claude-sonnet-5-5';

// Secret Manager no admite un valor vacío, así que el placeholder "sin
// clave todavía" es este literal en vez de una cadena vacía.
const SIN_CLAVE = 'DEMO_MODE_SIN_CLAVE';
function claveConfigurada(apiKey) {
  return apiKey && apiKey !== SIN_CLAVE;
}

const CATEGORIAS = ['lavadora_secadora', 'lavavajillas', 'frigorifico_congelador', 'horno_placa', 'aire_acondicionado', 'pequeno_electrodomestico', 'otro'];

// =============================================================================
// Cuota diaria por usuario -- sin esto, una clave real de Anthropic
// configurada no tiene ningún freno de gasto: un usuario (o un cliente
// comprometido que llame a la función saltándose la app) podría generar
// llamadas sin límite. Solo se aplica cuando hay clave real -- en modo
// demo no hay coste real que proteger.
// =============================================================================

const LIMITE_IDENTIFICACIONES_DIARIO = 30;
const LIMITE_MENSAJES_DIAGNOSTICO_DIARIO = 60;

function fechaHoyUtc() {
  return new Date().toISOString().slice(0, 10);
}

async function comprobarYRegistrarUso(uid, campo, limite) {
  const db = admin.firestore();
  const ref = db.collection('users').doc(uid).collection('uso').doc(fechaHoyUtc());
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const actual = (snap.exists && snap.data()[campo]) || 0;
    if (actual >= limite) {
      throw new HttpsError('resource-exhausted', 'Has alcanzado el límite diario de uso de IA. Inténtalo de nuevo mañana.');
    }
    tx.set(ref, { [campo]: actual + 1 }, { merge: true });
  });
}

// =============================================================================
// Identificación de electrodomésticos -- nunca inventa fabricante/modelo:
// solo los devuelve si hay evidencia visual suficiente (p. ej. una
// etiqueta legible). Demo determinista si no hay clave de Anthropic.
// =============================================================================

const IDENTIFY_TOOL = {
  name: 'identificar_electrodomestico',
  description: 'Registra la identificación de un electrodoméstico a partir de su fotografía.',
  input_schema: {
    type: 'object',
    properties: {
      category: { type: 'string', enum: CATEGORIAS },
      manufacturer: { type: 'string', description: 'Solo si es legible con certeza razonable (p. ej. en una etiqueta). Omite si no.' },
      model: { type: 'string', description: 'Solo si es legible con certeza razonable. Omite si no.' },
      confidence: { type: 'number', minimum: 0, maximum: 1, description: 'Confianza en la identificación de fabricante/modelo, no solo de la categoría.' },
      visible_controls: { type: 'array', items: { type: 'string' }, description: 'Controles/mandos visibles en la foto, en español sencillo.' },
      uncertainties: { type: 'array', items: { type: 'string' }, description: 'Qué no se puede determinar con esta foto.' },
      summary: { type: 'string', description: '1-2 frases en español describiendo lo identificado.' },
    },
    required: ['category', 'confidence', 'visible_controls', 'uncertainties', 'summary'],
  },
};

const IDENTIFY_SYSTEM_PROMPT = `Eres el motor de identificación visual de Lumio, una app que enseña a la gente a usar y entender los
electrodomésticos de su casa.
Analizas UNA fotografía de un electrodoméstico y devuelves solo lo que puedes determinar con evidencia real de la imagen.
Reglas estrictas:
- No inventes nunca un fabricante o modelo. Solo los indiques si hay una etiqueta o logo legible en la foto.
- Si no se ve ninguna etiqueta, omite fabricante y modelo por completo -- no asumas nada a partir de la forma o el color.
- "confidence" refleja tu seguridad en fabricante/modelo, no en la categoría general (que suele ser obvia).
- Lista en "uncertainties" lo que no puedes saber con esta única foto (p. ej. "no se ve la etiqueta de modelo").
- Responde siempre en español.
Responde solo llamando a la herramienta identificar_electrodomestico.`;

function demoIdentificacion() {
  return {
    mode: 'demo',
    category: 'lavadora_secadora',
    manufacturer: null,
    model: null,
    confidence: 0.3,
    visibleControls: ['Selector de programa', 'Botón de inicio/pausa', 'Pantalla de tiempo restante'],
    uncertainties: ['No hay clave de IA configurada: esta es una identificación de ejemplo, no un análisis real de tu foto.'],
    summary: 'Identificación de ejemplo (modo demostración): se asume una lavadora genérica para poder recorrer la app sin clave de IA.',
  };
}

exports.identificarElectrodomestico = onCall({ region: REGION, secrets: [_anthropicKey] }, async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Debes estar autenticado.');

  const { storagePath } = request.data;
  if (typeof storagePath !== 'string' || !storagePath.startsWith(`users/${request.auth.uid}/`)) {
    throw new HttpsError('invalid-argument', 'Parámetros inválidos.');
  }

  const apiKey = _anthropicKey.value();
  if (!claveConfigurada(apiKey)) return demoIdentificacion();

  await comprobarYRegistrarUso(request.auth.uid, 'identificaciones', LIMITE_IDENTIFICACIONES_DIARIO);

  const bucket = admin.storage().bucket();
  const [bytes] = await bucket.file(storagePath).download();
  const base64 = bytes.toString('base64');

  let res;
  try {
    res = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: { 'x-api-key': apiKey, 'anthropic-version': '2023-06-01', 'content-type': 'application/json' },
      body: JSON.stringify({
        model: MODEL,
        max_tokens: 1024,
        system: IDENTIFY_SYSTEM_PROMPT,
        tools: [IDENTIFY_TOOL],
        tool_choice: { type: 'tool', name: 'identificar_electrodomestico' },
        messages: [
          {
            role: 'user',
            content: [
              { type: 'image', source: { type: 'base64', media_type: 'image/jpeg', data: base64 } },
              { type: 'text', text: 'Identifica este electrodoméstico.' },
            ],
          },
        ],
      }),
    });
  } catch (e) {
    console.error('identificarElectrodomestico fetch error:', e);
    throw new HttpsError('unavailable', 'No se pudo contactar con el servicio de IA.');
  }

  if (!res.ok) {
    const body = await res.text().catch(() => '');
    console.error(`identificarElectrodomestico Anthropic error ${res.status}:`, body);
    throw new HttpsError('internal', `Error del servicio de IA: ${res.status}`);
  }

  const data = await res.json();
  const toolUse = (data.content || []).find((b) => b.type === 'tool_use');
  if (!toolUse) throw new HttpsError('internal', 'El modelo no devolvió una identificación estructurada.');

  const raw = toolUse.input;
  return {
    mode: 'real',
    category: raw.category,
    manufacturer: raw.manufacturer || null,
    model: raw.model || null,
    confidence: raw.confidence,
    visibleControls: raw.visible_controls || [],
    uncertainties: raw.uncertainties || [],
    summary: raw.summary,
  };
});

// =============================================================================
// Diagnóstico guiado -- un turno de conversación por llamada. Prioriza
// seguridad, hace preguntas concretas antes de proponer causas, nunca
// afirma un diagnóstico sin evidencia del usuario.
// =============================================================================

const TROUBLESHOOT_TOOL = {
  name: 'responder_diagnostico',
  description: 'Registra el siguiente turno del asistente de diagnóstico.',
  input_schema: {
    type: 'object',
    properties: {
      content: { type: 'string', description: 'Respuesta en español: una pregunta concreta, un aviso de seguridad, o causas posibles con evidencia.' },
      status: { type: 'string', enum: ['investigando', 'resuelto', 'necesitaMasInfo', 'escaladoProfesional', 'noUsarHastaRevisar'] },
      safety_flag: { type: 'boolean', description: 'true si este turno incluye un aviso de seguridad relevante (riesgo eléctrico, gas, humo, etc.).' },
    },
    required: ['content', 'status', 'safety_flag'],
  },
};

const TROUBLESHOOT_SYSTEM_PROMPT = `Eres el asistente de diagnóstico guiado de Lumio para electrodomésticos domésticos.
Tu objetivo es ayudar a investigar un problema de forma segura, enseñando mientras ayudas -- nunca afirmas una avería
concreta sin evidencia del usuario.
Reglas estrictas:
- Primero evalúa seguridad: si hay indicios de riesgo eléctrico, olor a quemado, humo, fuga de gas o fugas de agua
  importantes, tu primera respuesta debe ser un aviso claro de parar y, si corresponde, contactar a un profesional o
  servicio de emergencia -- marca safety_flag=true y status="noUsarHastaRevisar" o "escaladoProfesional".
- Nunca pidas al usuario que abra componentes eléctricos, manipule partes bajo tensión o se salte dispositivos de
  seguridad.
- Haz una pregunta concreta cada vez, no una lista larga. Espera la respuesta antes de seguir si el resultado cambia
  el camino a seguir.
- Cuando tengas indicios suficientes, presenta 2-3 causas posibles como mucho, explicando por qué encaja cada una y
  qué falta por saber -- nunca des un porcentaje de confianza inventado.
- Si la información sigue siendo insuficiente, dilo honestamente (status="necesitaMasInfo").
- Si el usuario confirma que el problema se ha resuelto, usa status="resuelto".
- Responde siempre en español, de forma breve y concreta.
Responde solo llamando a la herramienta responder_diagnostico.`;

// El diferenciador frente a abrir una conversación nueva en un chat de IA
// genérico: Lumio recuerda lo que ya pasó con ESTE electrodoméstico
// concreto. Se consulta bajo el propio namespace del usuario autenticado
// (nunca una ruta arbitraria pasada por el cliente), así que un
// electrodomesticoId ajeno o inventado simplemente no encuentra nada --
// no hay riesgo de fuga entre usuarios.
async function obtenerHistorialPrevio(uid, electrodomesticoId) {
  if (typeof electrodomesticoId !== 'string' || !electrodomesticoId) return [];
  const db = admin.firestore();
  const snap = await db.collection('users').doc(uid).collection('diagnosticos').where('electrodomesticoId', '==', electrodomesticoId).get();
  const relevantes = snap.docs
    .map((d) => d.data())
    .filter((d) => d.estado === 'resuelto' || d.estado === 'escaladoProfesional')
    .sort((a, b) => (b.updatedAt?.toMillis?.() || 0) - (a.updatedAt?.toMillis?.() || 0))
    .slice(0, 5);
  return relevantes.map((d) => {
    const fecha = d.updatedAt?.toDate?.() ? d.updatedAt.toDate().toISOString().slice(0, 10) : 'fecha desconocida';
    const estado = d.estado === 'resuelto' ? 'resuelto' : 'escalado a un profesional';
    return `- ${fecha}: "${d.sintoma}" (${estado})`;
  });
}

function demoRespuestaDiagnostico(messages) {
  const turnos = messages.filter((m) => m.role === 'user').length;
  if (turnos <= 1) {
    return {
      mode: 'demo',
      content: '(Modo demostración, sin clave de IA) Para investigarlo mejor: ¿el problema ocurre siempre, o solo a veces?',
      status: 'investigando',
      safetyFlag: false,
    };
  }
  return {
    mode: 'demo',
    content: '(Modo demostración, sin clave de IA) Con una clave de Anthropic configurada, aquí te daría posibles causas concretas basadas en tus respuestas, citando qué evidencia las respalda.',
    status: 'necesitaMasInfo',
    safetyFlag: false,
  };
}

exports.investigarProblema = onCall({ region: REGION, secrets: [_anthropicKey] }, async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Debes estar autenticado.');

  const { messages, electrodomesticoId } = request.data;
  if (!Array.isArray(messages) || messages.length === 0) {
    throw new HttpsError('invalid-argument', 'Falta el historial de la conversación.');
  }
  if (messages.length > 40) {
    throw new HttpsError('invalid-argument', 'Conversación demasiado larga.');
  }

  const apiKey = _anthropicKey.value();
  if (!claveConfigurada(apiKey)) return demoRespuestaDiagnostico(messages);

  await comprobarYRegistrarUso(request.auth.uid, 'mensajesDiagnostico', LIMITE_MENSAJES_DIAGNOSTICO_DIARIO);

  const historialPrevio = await obtenerHistorialPrevio(request.auth.uid, electrodomesticoId);
  const systemPrompt = historialPrevio.length
    ? `${TROUBLESHOOT_SYSTEM_PROMPT}\n\nHistorial conocido de este electrodoméstico (solo como referencia -- no asumas que la causa actual es la misma sin evidencia nueva del usuario en esta conversación):\n${historialPrevio.join('\n')}`
    : TROUBLESHOOT_SYSTEM_PROMPT;

  let res;
  try {
    res = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: { 'x-api-key': apiKey, 'anthropic-version': '2023-06-01', 'content-type': 'application/json' },
      body: JSON.stringify({
        model: MODEL,
        max_tokens: 1024,
        system: systemPrompt,
        tools: [TROUBLESHOOT_TOOL],
        tool_choice: { type: 'tool', name: 'responder_diagnostico' },
        messages: messages.map((m) => ({ role: m.role === 'assistant' ? 'assistant' : 'user', content: m.content })),
      }),
    });
  } catch (e) {
    console.error('investigarProblema fetch error:', e);
    throw new HttpsError('unavailable', 'No se pudo contactar con el servicio de IA.');
  }

  if (!res.ok) {
    const body = await res.text().catch(() => '');
    console.error(`investigarProblema Anthropic error ${res.status}:`, body);
    throw new HttpsError('internal', `Error del servicio de IA: ${res.status}`);
  }

  const data = await res.json();
  const toolUse = (data.content || []).find((b) => b.type === 'tool_use');
  if (!toolUse) throw new HttpsError('internal', 'El modelo no devolvió una respuesta estructurada.');

  const raw = toolUse.input;
  return { mode: 'real', content: raw.content, status: raw.status, safetyFlag: raw.safety_flag === true, tuvoHistorialPrevio: historialPrevio.length > 0 };
});

// =============================================================================
// Limpieza de datos al eliminar una cuenta -- se dispara DESPUÉS de que
// Firebase Auth ya ha borrado al usuario de verdad, así que puede usar
// privilegios de administrador sin depender de que el cliente siga
// autenticado (ver lib/services/cuenta_service.dart para el porqué del
// orden: borrar Auth primero, limpiar datos después).
// =============================================================================

exports.limpiarDatosUsuario = functionsV1.region(REGION).auth.user().onDelete(async (user) => {
  const uid = user.uid;
  const db = admin.firestore();
  const userRef = db.collection('users').doc(uid);

  const electrodomesticos = await userRef.collection('electrodomesticos').get();
  for (const doc of electrodomesticos.docs) {
    const storagePath = doc.data().storagePath;
    if (storagePath) {
      try {
        await admin.storage().bucket().file(storagePath).delete();
      } catch (e) {
        console.error(`limpiarDatosUsuario: no se pudo borrar ${storagePath}:`, e);
      }
    }
  }

  // Por si quedó algún objeto en Storage no referenciado en ningún
  // documento (p. ej. una foto subida durante una identificación que
  // nunca se llegó a guardar como electrodoméstico).
  try {
    await admin.storage().bucket().deleteFiles({ prefix: `users/${uid}/` });
  } catch (e) {
    console.error(`limpiarDatosUsuario: no se pudo limpiar el prefijo de Storage de ${uid}:`, e);
  }

  await db.recursiveDelete(userRef);
});
