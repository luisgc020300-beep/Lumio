// lib/screens/leccion_screen.dart
import 'package:flutter/material.dart';

import '../data/mensajes_profesor.dart';
import '../models/leccion.dart';
import '../services/leccion_service.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_error.dart';
import '../widgets/profesor_lumio.dart';

class LeccionScreen extends StatefulWidget {
  const LeccionScreen({required this.leccion, required this.progresoId, this.pasoInicial = 0, super.key});
  final Leccion leccion;
  final String progresoId;
  final int pasoInicial;

  @override
  State<LeccionScreen> createState() => _LeccionScreenState();
}

class _LeccionScreenState extends State<LeccionScreen> {
  late int _paso = widget.pasoInicial.clamp(0, widget.leccion.pasos.length - 1);
  bool _avanzando = false;
  /// true cuando el bloque de comprobación del paso actual (todas sus
  /// preguntas, incluido el repaso de las falladas) ya se completó --
  /// lo informa `_ComprobacionMultiple` vía callback. Se reinicia al
  /// avanzar de paso.
  bool _comprobacionCompleta = false;

  bool get _esUltimo => _paso == widget.leccion.pasos.length - 1;

  bool get _quizSinResponder {
    final paso = widget.leccion.pasos[_paso];
    return paso.preguntas != null && !_comprobacionCompleta;
  }

  /// El profesor virtual acompaña TODOS los pasos, no solo bienvenida/
  /// comprobación/cierre -- para que la lección no se quede en puro texto
  /// a mitad de camino. Cuando el paso ya tiene `porQueImporta` escrito,
  /// el profesor dice exactamente ese texto (sustituye al recuadro suelto
  /// que había antes); si no, un comentario breve de transición fijo, sin
  /// inventar contenido educativo nuevo. Los pasos de comprobación llevan
  /// su propio profesor dentro de `_ComprobacionMultiple` (necesita el
  /// estado fino de pregunta actual), así que no se gestionan aquí.
  ({PoseProfesor pose, String mensaje}) _contextoProfesor(PasoLeccion paso) {
    if (paso.tipo == TipoPasoLeccion.resumen) {
      return (pose: PoseProfesor.celebrando, mensaje: cierreLeccion(widget.leccion.id));
    }
    if (_paso == 0) {
      return (pose: PoseProfesor.saludo, mensaje: saludoLeccion(widget.leccion.titulo));
    }
    if (paso.porQueImporta != null) {
      return (pose: PoseProfesor.saludo, mensaje: paso.porQueImporta!);
    }
    return (pose: PoseProfesor.saludo, mensaje: comentarioTransicion(widget.leccion.id, _paso));
  }

  /// true si el profesor va antes del cuerpo del paso (bienvenida, cierre
  /// -- casos donde abre el paso) en vez de después (comentario ligado a
  /// lo que se acaba de leer).
  bool _profesorVaAntesDelCuerpo(PasoLeccion paso) => paso.tipo == TipoPasoLeccion.resumen || _paso == 0;

  Future<void> _siguiente() async {
    setState(() => _avanzando = true);
    try {
      if (_esUltimo) {
        await LeccionService.avanzarPaso(widget.progresoId, _paso, esUltimoPaso: true);
        if (mounted) await _mostrarResumen();
        return;
      }
      await LeccionService.avanzarPaso(widget.progresoId, _paso + 1, esUltimoPaso: false);
      if (mounted) {
        setState(() {
          _paso += 1;
          _comprobacionCompleta = false;
        });
      }
    } catch (e, st) {
      if (mounted) AppError.show(context, 'No se ha podido guardar tu progreso. Inténtalo de nuevo.', error: e, stackTrace: st);
    } finally {
      // Si "Terminar" ya cerró esta pantalla, el widget está desmontado --
      // sin este chequeo, el botón se queda bloqueado para siempre si el
      // usuario cierra la hoja deslizando en vez de pulsar el botón.
      if (mounted) setState(() => _avanzando = false);
    }
  }

  Future<void> _mostrarResumen() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(LumioSpace.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfesorLumio(pose: PoseProfesor.celebrando, mensaje: cierreLeccion(widget.leccion.id)),
            const SizedBox(height: LumioSpace.s3),
            Text('¡Lección completada!', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: LumioSpace.s2),
            Text(widget.leccion.objetivo, textAlign: TextAlign.center, style: TextStyle(color: context.colors.inkMuted)),
            const SizedBox(height: LumioSpace.s5),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Terminar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paso = widget.leccion.pasos[_paso];
    final progreso = (_paso + 1) / widget.leccion.pasos.length;
    final contextoProfesor = _contextoProfesor(paso);
    final profesorAntes = _profesorVaAntesDelCuerpo(paso);

    return Scaffold(
      appBar: AppBar(title: Text(widget.leccion.titulo, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: Column(
        children: [
          LinearProgressIndicator(value: progreso, minHeight: 3),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(LumioSpace.s5),
              children: [
                Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(color: context.colors.brand, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text('${_paso + 1}', style: TextStyle(color: context.colors.brandOn, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Text(_etiquetaTipo(paso.tipo), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: context.colors.brand)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(paso.titulo, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 22)),
                if (profesorAntes) ...[
                  const SizedBox(height: LumioSpace.s3),
                  ProfesorLumio(pose: contextoProfesor.pose, mensaje: contextoProfesor.mensaje),
                ],
                if (paso.imagenAsset != null) ...[
                  const SizedBox(height: LumioSpace.s4),
                  _IlustracionPaso(asset: paso.imagenAsset!, descripcion: paso.titulo),
                ],
                const SizedBox(height: LumioSpace.s4),
                Text(paso.cuerpo, style: const TextStyle(fontSize: 15, height: 1.4)),
                if (paso.preguntas != null) ...[
                  const SizedBox(height: LumioSpace.s4),
                  _ComprobacionMultiple(
                    key: ValueKey('${widget.leccion.id}-comprobacion-$_paso'),
                    leccionId: widget.leccion.id,
                    preguntas: paso.preguntas!,
                    onCompletado: () => setState(() => _comprobacionCompleta = true),
                  ),
                ] else if (!profesorAntes) ...[
                  const SizedBox(height: LumioSpace.s4),
                  ProfesorLumio(pose: contextoProfesor.pose, mensaje: contextoProfesor.mensaje),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(LumioSpace.s4),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: (_avanzando || _quizSinResponder) ? null : _siguiente, child: Text(_esUltimo ? 'Terminar lección' : 'Siguiente')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _etiquetaTipo(TipoPasoLeccion t) => switch (t) {
        TipoPasoLeccion.explicacion => 'EXPLICACIÓN',
        TipoPasoLeccion.visual => 'CÓMO FUNCIONA',
        TipoPasoLeccion.tarea => 'TAREA PRÁCTICA',
        TipoPasoLeccion.comprobacion => 'COMPRUEBA LO APRENDIDO',
        TipoPasoLeccion.resumen => 'RESUMEN',
      };
}

/// Ilustración 2D de catálogo (asset local, nunca una llamada de red) --
/// se omite sin dejar hueco cuando el paso no tiene una asociada.
class _IlustracionPaso extends StatelessWidget {
  const _IlustracionPaso({required this.asset, required this.descripcion});
  final String asset;
  final String descripcion;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Ilustración: $descripcion',
      child: ExcludeSemantics(
        child: Container(
          width: double.infinity,
          height: 200,
          padding: const EdgeInsets.all(LumioSpace.s2),
          decoration: BoxDecoration(color: context.colors.surfaceMuted, borderRadius: BorderRadius.circular(LumioRadius.md)),
          child: Image.asset(asset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

/// Comprobación con varias preguntas: selección inmediata = feedback
/// inmediato (un único control de acción por pantalla, igual criterio que
/// el resto de Lumio), pero una vez respondida una pregunta queda fijada
/// -- no se puede cambiar en el momento. Si se falla en el primer
/// intento, esa pregunta se vuelve a hacer al final, después de las
/// demás (una sola vuelta de repaso, no un bucle hasta acertar).
class _ComprobacionMultiple extends StatefulWidget {
  const _ComprobacionMultiple({required this.leccionId, required this.preguntas, required this.onCompletado, super.key});
  final String leccionId;
  final List<PreguntaQuiz> preguntas;
  final VoidCallback onCompletado;

  @override
  State<_ComprobacionMultiple> createState() => _ComprobacionMultipleState();
}

class _ComprobacionMultipleState extends State<_ComprobacionMultiple> {
  late List<PreguntaQuiz> _cola = List.of(widget.preguntas);
  final List<PreguntaQuiz> _falladasPrimerIntento = [];
  bool _enRepaso = false;
  bool _terminado = false;
  int? _seleccion;
  int _numeroPregunta = 1;
  int _aciertosPrimerIntento = 0;

  void _seleccionar(int i) {
    if (_seleccion != null) return; // ya respondida -- se fija hasta "Siguiente pregunta"
    setState(() {
      _seleccion = i;
      if (!_enRepaso) {
        if (i == _cola.first.respuestaCorrecta) {
          _aciertosPrimerIntento++;
        } else {
          _falladasPrimerIntento.add(_cola.first);
        }
      }
    });
  }

  void _siguientePregunta() {
    setState(() {
      _cola.removeAt(0);
      _seleccion = null;
      if (_cola.isNotEmpty) {
        _numeroPregunta++;
        return;
      }
      if (!_enRepaso && _falladasPrimerIntento.isNotEmpty) {
        _cola = List.of(_falladasPrimerIntento);
        _falladasPrimerIntento.clear();
        _enRepaso = true;
        _numeroPregunta = 1;
      } else {
        _terminado = true;
        widget.onCompletado();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_terminado) {
      final perfecto = _aciertosPrimerIntento == widget.preguntas.length;
      final mensaje = perfecto
          ? '¡Las acertaste todas a la primera!'
          : '$_aciertosPrimerIntento de ${widget.preguntas.length} a la primera -- el resto ya las has repasado.';
      return ProfesorLumio(pose: PoseProfesor.celebrando, mensaje: mensaje);
    }

    final pregunta = _cola.first;
    final respondido = _seleccion != null;
    final acerto = _seleccion == pregunta.respuestaCorrecta;

    final ({PoseProfesor pose, String mensaje}) contexto;
    if (!respondido) {
      contexto = (pose: PoseProfesor.saludo, mensaje: pistaComprobacion(widget.leccionId));
    } else if (acerto) {
      contexto = (pose: PoseProfesor.celebrando, mensaje: feedbackCorrecto(widget.leccionId));
    } else {
      contexto = (pose: PoseProfesor.animando, mensaje: feedbackIncorrecto(widget.leccionId));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfesorLumio(pose: contexto.pose, mensaje: contexto.mensaje),
        const SizedBox(height: LumioSpace.s3),
        Text(
          _enRepaso ? 'Repasemos esta' : 'Pregunta $_numeroPregunta de ${widget.preguntas.length}',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: context.colors.brand),
        ),
        const SizedBox(height: LumioSpace.s2),
        Text(pregunta.pregunta, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: LumioSpace.s3),
        for (var i = 0; i < pregunta.opciones.length; i++) ...[
          _OpcionQuiz(
            texto: pregunta.opciones[i],
            esCorrecta: i == pregunta.respuestaCorrecta,
            esSeleccionada: i == _seleccion,
            mostrarResultado: respondido,
            onTap: () => _seleccionar(i),
          ),
          if (i != pregunta.opciones.length - 1) const SizedBox(height: LumioSpace.s2),
        ],
        if (respondido) ...[
          const SizedBox(height: LumioSpace.s4),
          Container(
            padding: const EdgeInsets.all(LumioSpace.s3),
            decoration: BoxDecoration(
              color: (acerto ? context.colors.success : context.colors.error).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(LumioRadius.sm),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(acerto ? Icons.check_circle_outline : Icons.cancel_outlined, size: 18, color: acerto ? context.colors.success : context.colors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  acerto ? (pregunta.explicacion ?? '¡Correcto!') : 'Esa no es. ${pregunta.explicacion ?? "Prueba con otra opción la próxima vez."}',
                  style: TextStyle(fontSize: 13, color: acerto ? context.colors.ink : context.colors.errorText),
                ),
              ),
            ]),
          ),
          const SizedBox(height: LumioSpace.s3),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _siguientePregunta, child: const Text('Siguiente pregunta'))),
        ],
      ],
    );
  }
}

class _OpcionQuiz extends StatelessWidget {
  const _OpcionQuiz({required this.texto, required this.esCorrecta, required this.esSeleccionada, required this.mostrarResultado, required this.onTap});
  final String texto;
  final bool esCorrecta;
  final bool esSeleccionada;
  final bool mostrarResultado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color borde = context.colors.ink.withValues(alpha: 0.15);
    Color? fondo;
    IconData? icono;
    Color? colorIcono;

    if (mostrarResultado && esCorrecta) {
      borde = context.colors.success;
      fondo = context.colors.success.withValues(alpha: 0.1);
      icono = Icons.check_circle_outline;
      colorIcono = context.colors.success;
    } else if (mostrarResultado && esSeleccionada) {
      borde = context.colors.error;
      fondo = context.colors.error.withValues(alpha: 0.1);
      icono = Icons.cancel_outlined;
      colorIcono = context.colors.error;
    } else if (esSeleccionada) {
      borde = context.colors.brand;
    }

    return Semantics(
      button: true,
      selected: esSeleccionada,
      label: texto,
      child: Material(
        color: fondo ?? Colors.transparent,
        borderRadius: BorderRadius.circular(LumioRadius.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(LumioRadius.sm),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: LumioSpace.s3, vertical: LumioSpace.s3),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(LumioRadius.sm), border: Border.all(color: borde, width: esSeleccionada ? 2 : 1)),
            child: Row(children: [
              Expanded(child: Text(texto, style: const TextStyle(fontSize: 14))),
              if (icono != null) ...[const SizedBox(width: 8), Icon(icono, size: 18, color: colorIcono)],
            ]),
          ),
        ),
      ),
    );
  }
}

/// Punto único de navegación a una lección -- evita repetir el mismo
/// `iniciarOContinuar` + `Navigator.push` en cada pantalla que enlaza a una.
Future<void> abrirLeccion(BuildContext context, Leccion leccion) async {
  final progresoId = await LeccionService.iniciarOContinuar(leccion.id);
  if (context.mounted) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => LeccionScreen(leccion: leccion, progresoId: progresoId)));
  }
}

/// Tarjeta de lección con la ilustración como cabecera -- usada en los
/// resultados de Explorar y en el carrusel "Para empezar" de Inicio.
/// Con las 9 lecciones del catálogo ya ilustradas (ver
/// lib/data/catalogo_lecciones.dart) esto siempre tiene una imagen real
/// que mostrar; el fallback con icono es solo para que una lección
/// futura sin ilustración no rompa el diseño.
class TarjetaLeccionVisual extends StatelessWidget {
  const TarjetaLeccionVisual({required this.leccion, this.width, this.alturaIlustracion = 120, super.key});
  final Leccion leccion;
  final double? width;
  final double alturaIlustracion;

  @override
  Widget build(BuildContext context) {
    final asset = leccion.primeraIlustracion;
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => abrirLeccion(context, leccion),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (asset != null)
                // BoxFit.contain (no .cover): las ilustraciones son 4:3 y la
                // cabecera es mucho más ancha que alta -- con .cover se
                // recortaba la mitad de la imagen por arriba y por abajo.
                Container(
                  height: alturaIlustracion,
                  width: double.infinity,
                  color: context.colors.surfaceMuted,
                  child: ExcludeSemantics(child: Image.asset(asset, fit: BoxFit.contain)),
                )
              else
                Container(
                  height: alturaIlustracion,
                  width: double.infinity,
                  color: context.colors.surfaceMuted,
                  alignment: Alignment.center,
                  child: Icon(Icons.auto_stories_outlined, color: context.colors.brand, size: 32),
                ),
              Padding(
                padding: const EdgeInsets.all(LumioSpace.s3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leccion.categoria.etiqueta,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: context.colors.brand),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(leccion.titulo, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(leccion.objetivo, style: TextStyle(fontSize: 12, color: context.colors.inkMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
