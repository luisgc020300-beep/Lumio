// lib/screens/home_tab.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/catalogo_lecciones.dart';
import '../models/electrodomestico.dart';
import '../models/leccion.dart';
import '../services/electrodomestico_service.dart';
import '../services/leccion_service.dart';
import '../theme/categoria_estilos.dart';
import '../theme/design_tokens.dart';
import '../widgets/empty_state.dart';
import 'ajustes_screen.dart';
import 'camara_screen.dart';
import 'diagnostico_screen.dart';
import 'electrodomestico_detail_screen.dart';
import 'leccion_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final nombre = email.contains('@') ? email.split('@').first : email;

    return Scaffold(
      appBar: AppBar(
        title: Text(nombre.isEmpty ? '¿Qué quieres aprender hoy?' : 'Hola, $nombre'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AjustesScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(LumioSpace.s4),
        children: [
          _TarjetaPrincipal(
            icon: Icons.photo_camera_outlined,
            titulo: 'Enséñame un aparato',
            subtitulo: 'Haz una foto y descubre cómo funciona.',
            botonPrimario: 'Usar cámara',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CamaraScreen())),
          ),
          const SizedBox(height: LumioSpace.s4),
          _TarjetaPrincipal(
            icon: Icons.build_outlined,
            titulo: 'Tengo un problema',
            subtitulo: 'Cuéntame qué ocurre y lo investigamos juntos.',
            botonPrimario: 'Empezar',
            tono: context.colors.lavanda,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DiagnosticoScreen())),
          ),
          const SizedBox(height: LumioSpace.s6),
          Text('Tus electrodomésticos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: LumioSpace.s2),
          StreamBuilder<List<Electrodomestico>>(
            stream: ElectrodomesticoService.streamElectrodomesticos(),
            builder: (context, snapshot) {
              final items = (snapshot.data ?? []).take(3).toList();
              if (items.isEmpty) {
                return const EmptyState(
                  icon: Icons.kitchen_outlined,
                  title: 'Todavía no has guardado ningún electrodoméstico',
                  description: 'Haz una foto con "Enséñame un aparato" para empezar.',
                );
              }
              return Column(
                children: items.map((e) {
                  final acento = colorCategoria(context, e.categoria);
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: acento.withValues(alpha: 0.15), child: Icon(iconoCategoria(e.categoria.icono), color: acento)),
                      title: Text(e.nombre),
                      subtitle: Text(e.modeloVerificado ? '${e.fabricante ?? ''} ${e.modelo ?? ''}'.trim() : e.categoria.etiqueta),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ElectrodomesticoDetailScreen(id: e.id))),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: LumioSpace.s6),
          Text('Para empezar', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: LumioSpace.s2),
          ...catalogoLecciones.take(2).map((l) => _TarjetaLeccionRecomendada(leccion: l)),
        ],
      ),
    );
  }

}

class _TarjetaPrincipal extends StatelessWidget {
  const _TarjetaPrincipal({required this.icon, required this.titulo, required this.subtitulo, required this.botonPrimario, required this.onTap, this.tono});
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final String botonPrimario;
  final VoidCallback onTap;
  final Color? tono;

  @override
  Widget build(BuildContext context) {
    final color = tono ?? context.colors.brand;
    return Container(
      padding: const EdgeInsets.all(LumioSpace.s5),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(LumioRadius.lg),
        boxShadow: [BoxShadow(color: context.colors.ink.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(LumioRadius.md)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: LumioSpace.s3),
          Text(titulo, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17)),
          const SizedBox(height: LumioSpace.s1),
          Text(subtitulo, style: TextStyle(color: context.colors.inkMuted, fontSize: 13)),
          const SizedBox(height: LumioSpace.s4),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: onTap, child: Text(botonPrimario))),
        ],
      ),
    );
  }
}

class _TarjetaLeccionRecomendada extends StatelessWidget {
  const _TarjetaLeccionRecomendada({required this.leccion});
  final Leccion leccion;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.auto_stories_outlined, color: context.colors.brand),
        title: Text(leccion.titulo),
        subtitle: Text(leccion.categoria.etiqueta),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final progresoId = await LeccionService.iniciarOContinuar(leccion.id);
          if (context.mounted) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => LeccionScreen(leccion: leccion, progresoId: progresoId)));
          }
        },
      ),
    );
  }
}
