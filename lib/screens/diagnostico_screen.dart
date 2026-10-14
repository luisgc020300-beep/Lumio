// lib/screens/diagnostico_screen.dart
import 'package:flutter/material.dart';

import '../models/diagnostico.dart';
import '../services/diagnostico_service.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_error.dart';

class DiagnosticoScreen extends StatefulWidget {
  const DiagnosticoScreen({this.sesionId, this.electrodomesticoId, super.key});
  final String? sesionId;
  final String? electrodomesticoId;

  @override
  State<DiagnosticoScreen> createState() => _DiagnosticoScreenState();
}

class _DiagnosticoScreenState extends State<DiagnosticoScreen> {
  String? _sesionId;
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _sesionId = widget.sesionId;
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarSintomaInicial(String sintoma) async {
    if (sintoma.trim().isEmpty) return;
    setState(() => _enviando = true);
    try {
      final id = await DiagnosticoService.crearSesion(sintoma.trim(), electrodomesticoId: widget.electrodomesticoId);
      await DiagnosticoService.enviarMensaje(id, sintoma.trim()); // dispara el primer turno del asistente
      if (mounted) {
        setState(() {
          _sesionId = id;
          _inputCtrl.clear();
        });
      }
    } catch (e) {
      if (mounted) AppError.show(context, 'No se ha podido iniciar el diagnóstico.', error: e);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _enviarMensaje() async {
    final texto = _inputCtrl.text.trim();
    if (texto.isEmpty || _sesionId == null) return;
    setState(() => _enviando = true);
    _inputCtrl.clear();
    try {
      await DiagnosticoService.enviarMensaje(_sesionId!, texto);
    } catch (e) {
      if (mounted) AppError.show(context, 'No se ha podido enviar.', error: e);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tengo un problema')),
      body: _sesionId == null ? _vistaInicial(context) : _vistaConversacion(context),
    );
  }

  Widget _vistaInicial(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(LumioSpace.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: context.colors.lavanda.withValues(alpha: 0.18), shape: BoxShape.circle),
              child: Icon(Icons.support_agent_outlined, size: 32, color: context.colors.lavanda),
            ),
          ),
          const SizedBox(height: LumioSpace.s4),
          Text('Cuéntame qué ocurre', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: LumioSpace.s2),
          Text('Lo investigamos juntos, paso a paso.', style: TextStyle(color: context.colors.inkMuted)),
          const SizedBox(height: LumioSpace.s4),
          TextField(
            controller: _inputCtrl,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Ej. "La lavadora no desagua"'),
          ),
          const SizedBox(height: LumioSpace.s3),
          FilledButton(
            onPressed: _enviando ? null : () => _enviarSintomaInicial(_inputCtrl.text),
            child: Text(_enviando ? 'Enviando...' : 'Empezar'),
          ),
        ],
      ),
    );
  }

  Widget _vistaConversacion(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<MensajeDiagnostico>>(
            stream: DiagnosticoService.streamMensajes(_sesionId!),
            builder: (context, snapshot) {
              final mensajes = snapshot.data ?? [];
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollCtrl.hasClients) _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
              });
              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(LumioSpace.s4),
                itemCount: mensajes.length,
                itemBuilder: (context, i) => _Burbuja(mensaje: mensajes[i]),
              );
            },
          ),
        ),
        if (_enviando) const LinearProgressIndicator(minHeight: 2),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(LumioSpace.s3),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _inputCtrl, decoration: const InputDecoration(hintText: 'Escribe tu respuesta...'), onSubmitted: (_) => _enviarMensaje())),
                IconButton(icon: const Icon(Icons.send), onPressed: _enviando ? null : _enviarMensaje),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Burbuja extends StatelessWidget {
  const _Burbuja({required this.mensaje});
  final MensajeDiagnostico mensaje;

  @override
  Widget build(BuildContext context) {
    final esUsuario = mensaje.rol == 'user';
    final esAviso = mensaje.esAvisoSeguridad;
    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: esAviso ? context.colors.error.withValues(alpha: 0.15) : (esUsuario ? context.colors.brand : context.colors.surfaceMuted),
          borderRadius: BorderRadius.circular(LumioRadius.md),
          border: esAviso ? Border.all(color: context.colors.error) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (esAviso)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.warning_amber_outlined, size: 16, color: context.colors.errorText),
                  const SizedBox(width: 4),
                  Text('Aviso de seguridad', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.colors.errorText)),
                ]),
              ),
            Text(mensaje.contenido, style: TextStyle(color: esAviso ? context.colors.errorText : (esUsuario ? context.colors.brandOn : context.colors.ink))),
          ],
        ),
      ),
    );
  }
}
