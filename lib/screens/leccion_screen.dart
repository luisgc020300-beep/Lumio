// lib/screens/leccion_screen.dart
import 'package:flutter/material.dart';

import '../models/leccion.dart';
import '../services/leccion_service.dart';
import '../theme/design_tokens.dart';

class LeccionScreen extends StatefulWidget {
  const LeccionScreen({required this.leccion, required this.progresoId, super.key});
  final Leccion leccion;
  final String progresoId;

  @override
  State<LeccionScreen> createState() => _LeccionScreenState();
}

class _LeccionScreenState extends State<LeccionScreen> {
  int _paso = 0;
  bool _avanzando = false;

  bool get _esUltimo => _paso == widget.leccion.pasos.length - 1;

  Future<void> _siguiente() async {
    if (_esUltimo) {
      setState(() => _avanzando = true);
      await LeccionService.avanzarPaso(widget.progresoId, _paso, esUltimoPaso: true);
      if (mounted) _mostrarResumen();
      return;
    }
    await LeccionService.avanzarPaso(widget.progresoId, _paso + 1, esUltimoPaso: false);
    setState(() => _paso += 1);
  }

  void _mostrarResumen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(LumioSpace.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.celebration_outlined, size: 40, color: context.colors.success),
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

    return Scaffold(
      appBar: AppBar(title: Text(widget.leccion.titulo, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: Column(
        children: [
          LinearProgressIndicator(value: progreso, minHeight: 3),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(LumioSpace.s5),
              children: [
                Text(_etiquetaTipo(paso.tipo), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: context.colors.brand)),
                const SizedBox(height: 6),
                Text(paso.titulo, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 22)),
                const SizedBox(height: LumioSpace.s4),
                Text(paso.cuerpo, style: const TextStyle(fontSize: 15, height: 1.4)),
                if (paso.porQueImporta != null) ...[
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
              child: FilledButton(onPressed: _avanzando ? null : _siguiente, child: Text(_esUltimo ? 'Terminar lección' : 'Siguiente')),
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
