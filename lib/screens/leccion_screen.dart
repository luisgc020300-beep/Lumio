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
  /// Opción elegida en el paso de comprobación actual -- se reinicia al
  /// avanzar de paso. Vive aquí (no en un widget hijo) porque es el estado
  /// más simple posible para un quiz de un único paso visible a la vez.
  int? _seleccionQuiz;

  bool get _esUltimo => _paso == widget.leccion.pasos.length - 1;

  bool get _quizSinResponder {
    final paso = widget.leccion.pasos[_paso];
    return paso.opciones != null && _seleccionQuiz == null;
  }

  /// Dónde y con qué mensaje aparece el profesor virtual -- selectivo, no
  /// en cada paso: solo en la bienvenida, en la comprobación (antes y
  /// después de responder) y en el cierre, para no saturar la pantalla.
  ({PoseProfesor pose, String mensaje})? _contextoProfesor(PasoLeccion paso) {
    if (paso.tipo == TipoPasoLeccion.comprobacion && paso.opciones != null) {
      if (_seleccionQuiz == null) {
        return (pose: PoseProfesor.saludo, mensaje: pistaComprobacion(widget.leccion.id));
      }
      final acerto = _seleccionQuiz == paso.respuestaCorrecta;
      return acerto
          ? (pose: PoseProfesor.celebrando, mensaje: feedbackCorrecto(widget.leccion.id))
          : (pose: PoseProfesor.animando, mensaje: feedbackIncorrecto(widget.leccion.id));
    }
    if (paso.tipo == TipoPasoLeccion.resumen) {
      return (pose: PoseProfesor.celebrando, mensaje: cierreLeccion(widget.leccion.id));
    }
    if (_paso == 0) {
      return (pose: PoseProfesor.saludo, mensaje: saludoLeccion(widget.leccion.titulo));
    }
    return null;
  }

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
          _seleccionQuiz = null;
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
                if (contextoProfesor != null) ...[
                  const SizedBox(height: LumioSpace.s3),
                  ProfesorLumio(pose: contextoProfesor.pose, mensaje: contextoProfesor.mensaje),
                ],
                if (paso.imagenAsset != null) ...[
                  const SizedBox(height: LumioSpace.s4),
                  _IlustracionPaso(asset: paso.imagenAsset!, descripcion: paso.titulo),
                ],
                const SizedBox(height: LumioSpace.s4),
                Text(paso.cuerpo, style: const TextStyle(fontSize: 15, height: 1.4)),
                if (paso.opciones != null) ...[
                  const SizedBox(height: LumioSpace.s4),
                  _Comprobacion(
                    opciones: paso.opciones!,
                    correcta: paso.respuestaCorrecta!,
                    explicacion: paso.porQueImporta,
                    seleccion: _seleccionQuiz,
                    onSeleccionar: (i) => setState(() => _seleccionQuiz = i),
                  ),
                ] else if (paso.porQueImporta != null) ...[
                  const SizedBox(height: LumioSpace.s4),
                  Container(
                    padding: const EdgeInsets.all(LumioSpace.s3),
                    decoration: BoxDecoration(color: context.colors.brandTint, borderRadius: BorderRadius.circular(LumioRadius.sm)),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.lightbulb_outline, size: 18, color: context.colors.brand),
                      const SizedBox(width: 8),
                      Expanded(child: Text(paso.porQueImporta!, style: TextStyle(fontSize: 13, color: context.colors.ink))),
                    ]),
                  ),
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

/// Comprobación interactiva real: selección inmediata = feedback inmediato,
/// sin botón "Comprobar" aparte -- un único control de acción por pantalla,
/// igual que el resto de Lumio. Una respuesta incorrecta no bloquea seguir
/// probando otras opciones.
class _Comprobacion extends StatelessWidget {
  const _Comprobacion({
    required this.opciones,
    required this.correcta,
    required this.explicacion,
    required this.seleccion,
    required this.onSeleccionar,
  });

  final List<String> opciones;
  final int correcta;
  final String? explicacion;
  final int? seleccion;
  final ValueChanged<int> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    final respondido = seleccion != null;
    final acerto = seleccion == correcta;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < opciones.length; i++) ...[
          _OpcionQuiz(
            texto: opciones[i],
            esCorrecta: i == correcta,
            esSeleccionada: i == seleccion,
            mostrarResultado: respondido,
            onTap: () => onSeleccionar(i),
          ),
          if (i != opciones.length - 1) const SizedBox(height: LumioSpace.s2),
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
                  acerto
                      ? (explicacion ?? '¡Correcto!')
                      : 'Esa no es. ${explicacion != null ? explicacion! : "Prueba con otra opción."}',
                  style: TextStyle(fontSize: 13, color: acerto ? context.colors.ink : context.colors.errorText),
                ),
              ),
            ]),
          ),
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
  const TarjetaLeccionVisual({required this.leccion, this.width, super.key});
  final Leccion leccion;
  final double? width;

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
                ExcludeSemantics(child: Image.asset(asset, height: 120, width: double.infinity, fit: BoxFit.cover))
              else
                Container(
                  height: 120,
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
