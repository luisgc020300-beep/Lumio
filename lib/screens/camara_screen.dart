// lib/screens/camara_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/electrodomestico_service.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_error.dart';
import 'diagnostico_screen.dart';
import 'electrodomestico_detail_screen.dart';

enum _EstadoCamara { inicial, procesando, resultado }

class CamaraScreen extends StatefulWidget {
  const CamaraScreen({super.key});

  @override
  State<CamaraScreen> createState() => _CamaraScreenState();
}

class _CamaraScreenState extends State<CamaraScreen> {
  _EstadoCamara _estado = _EstadoCamara.inicial;
  File? _foto;
  IdentificacionResultado? _resultado;
  String? _error;
  bool _guardando = false;

  Future<void> _elegirFoto(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    setState(() {
      _foto = File(picked.path);
      _estado = _EstadoCamara.procesando;
      _error = null;
    });
    try {
      final resultado = await ElectrodomesticoService.identificar(_foto!);
      if (mounted) {
        setState(() {
          _resultado = resultado;
          _estado = _EstadoCamara.resultado;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se ha podido analizar la foto. Inténtalo de nuevo.';
          _estado = _EstadoCamara.inicial;
        });
      }
    }
  }

  Future<void> _guardarYContinuar({required bool irADiagnostico}) async {
    setState(() => _guardando = true);
    try {
      final id = await ElectrodomesticoService.guardar(nombre: _nombreSugerido(), identificacion: _resultado!);
      if (!mounted) return;
      if (irADiagnostico) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DiagnosticoScreen(electrodomesticoId: id)));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ElectrodomesticoDetailScreen(id: id)));
      }
    } catch (e) {
      if (mounted) {
        AppError.show(context, 'No se ha podido guardar.', error: e);
        setState(() => _guardando = false);
      }
    }
  }

  String _nombreSugerido() {
    final r = _resultado!;
    if (r.fabricante != null && r.modelo != null) return '${r.fabricante} ${r.modelo}';
    return r.categoria.etiqueta;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enséñame un aparato')),
      body: switch (_estado) {
        _EstadoCamara.inicial => _vistaInicial(context),
        _EstadoCamara.procesando => _vistaProcesando(context),
        _EstadoCamara.resultado => _vistaResultado(context),
      },
    );
  }

  Widget _vistaInicial(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(LumioSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_camera_outlined, size: 56, color: context.colors.brand),
          const SizedBox(height: LumioSpace.s4),
          Text(
            'Fotografía el aparato completo. Después podremos acercarnos a los controles o a la etiqueta del modelo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.inkMuted),
          ),
          if (_error != null) ...[
            const SizedBox(height: LumioSpace.s3),
            Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: context.colors.errorText)),
          ],
          const SizedBox(height: LumioSpace.s6),
          FilledButton.icon(onPressed: () => _elegirFoto(ImageSource.camera), icon: const Icon(Icons.photo_camera), label: const Text('Usar cámara')),
          const SizedBox(height: LumioSpace.s3),
          OutlinedButton.icon(onPressed: () => _elegirFoto(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: const Text('Elegir una foto')),
        ],
      ),
    );
  }

  Widget _vistaProcesando(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_foto != null) ClipRRect(borderRadius: BorderRadius.circular(LumioRadius.md), child: Image.file(_foto!, width: 220, height: 220, fit: BoxFit.cover)),
          const SizedBox(height: LumioSpace.s5),
          const CircularProgressIndicator(),
          const SizedBox(height: LumioSpace.s3),
          const Text('Identificando...'),
        ],
      ),
    );
  }

  Widget _vistaResultado(BuildContext context) {
    final r = _resultado!;
    final esDemo = r.modo == 'demo';
    return ListView(
      padding: const EdgeInsets.all(LumioSpace.s4),
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(LumioRadius.lg), child: Image.file(_foto!, height: 220, width: double.infinity, fit: BoxFit.cover)),
        const SizedBox(height: LumioSpace.s4),
        if (esDemo)
          Container(
            padding: const EdgeInsets.all(LumioSpace.s3),
            margin: const EdgeInsets.only(bottom: LumioSpace.s3),
            decoration: BoxDecoration(color: context.colors.lavanda.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(LumioRadius.sm)),
            child: Row(children: [
              Icon(Icons.info_outline, size: 18, color: context.colors.ink),
              const SizedBox(width: 8),
              const Expanded(child: Text('Identificación de ejemplo (modo demostración) — no hay clave de IA configurada todavía.')),
            ]),
          ),
        Text(_nombreSugerido(), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18)),
        const SizedBox(height: LumioSpace.s2),
        Text(r.resumen, style: TextStyle(color: context.colors.inkMuted)),
        if (r.controlesVisibles.isNotEmpty) ...[
          const SizedBox(height: LumioSpace.s4),
          Text('Lo que reconocemos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          ...r.controlesVisibles.map((c) => Row(children: [const Icon(Icons.check_circle_outline, size: 16), const SizedBox(width: 6), Expanded(child: Text(c))])),
        ],
        if (r.incertidumbres.isNotEmpty) ...[
          const SizedBox(height: LumioSpace.s4),
          Text('Lo que no sabemos con certeza', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          ...r.incertidumbres.map((c) => Row(children: [Icon(Icons.help_outline, size: 16, color: context.colors.warningText), const SizedBox(width: 6), Expanded(child: Text(c))])),
        ],
        const SizedBox(height: LumioSpace.s6),
        FilledButton(onPressed: _guardando ? null : () => _guardarYContinuar(irADiagnostico: false), child: Text(_guardando ? 'Guardando...' : 'Aprender sobre este aparato')),
        const SizedBox(height: LumioSpace.s2),
        OutlinedButton(onPressed: _guardando ? null : () => _guardarYContinuar(irADiagnostico: true), child: const Text('Quiero solucionar un problema')),
      ],
    );
  }
}
