// lib/screens/home_tab.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/catalogo_lecciones.dart';
import '../data/mensajes_profesor.dart';
import '../models/electrodomestico.dart';
import '../services/analytics_service.dart';
import '../services/electrodomestico_service.dart';
import '../theme/categoria_estilos.dart';
import '../theme/design_tokens.dart';
import '../widgets/empty_state.dart';
import '../widgets/profesor_lumio.dart';
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
          const ProfesorLumio(pose: PoseProfesor.saludo, mensaje: saludoHome),
          const SizedBox(height: LumioSpace.s4),
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
          const _BannerGarantias(),
          const SizedBox(height: LumioSpace.s6),
          Text('Tus electrodomésticos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: LumioSpace.s2),
          StreamBuilder<List<Electrodomestico>>(
            stream: ElectrodomesticoService.streamElectrodomesticos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: LumioSpace.s4),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final items = (snapshot.data ?? []).take(6).toList();
              if (items.isEmpty) {
                return const EmptyState(
                  icon: Icons.kitchen_outlined,
                  title: 'Todavía no has guardado ningún electrodoméstico',
                  description: 'Haz una foto con "Enséñame un aparato" para empezar.',
                );
              }
              return SizedBox(
                height: 104,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: LumioSpace.s2),
                  itemBuilder: (context, i) => _TarjetaElectrodomesticoCompacta(electrodomestico: items[i]),
                ),
              );
            },
          ),
          const SizedBox(height: LumioSpace.s6),
          Text('Para empezar', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: LumioSpace.s2),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: catalogoLecciones.take(4).length,
              separatorBuilder: (_, _) => const SizedBox(width: LumioSpace.s3),
              itemBuilder: (context, i) => TarjetaLeccionVisual(leccion: catalogoLecciones[i], width: 200),
            ),
          ),
        ],
      ),
    );
  }

}

/// Motivo real para volver a abrir la app sin forzar un hábito diario
/// falso: avisa cuando la garantía de un electrodoméstico está a punto
/// de caducar. Solo se basa en datos que el propio usuario introdujo
/// (fecha de compra + duración) -- nunca se inventa ni se asume.
class _BannerGarantias extends StatefulWidget {
  const _BannerGarantias();

  @override
  State<_BannerGarantias> createState() => _BannerGarantiasState();
}

class _BannerGarantiasState extends State<_BannerGarantias> {
  bool _reportado = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Electrodomestico>>(
      stream: ElectrodomesticoService.streamElectrodomesticos(),
      builder: (context, snapshot) {
        final ahora = DateTime.now();
        final proximas = (snapshot.data ?? []).where((e) {
          final hasta = e.garantiaHasta;
          if (hasta == null) return false;
          final dias = hasta.difference(ahora).inDays;
          return dias >= 0 && dias <= 30;
        }).toList();
        if (proximas.isEmpty) return const SizedBox.shrink();
        if (!_reportado) {
          _reportado = true;
          AnalyticsService.garantiaBannerMostrado();
        }
        final e = proximas.first;
        final dias = e.garantiaHasta!.difference(ahora).inDays;
        return Padding(
          padding: const EdgeInsets.only(top: LumioSpace.s4),
          child: Material(
            color: context.colors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(LumioRadius.sm),
            child: InkWell(
              borderRadius: BorderRadius.circular(LumioRadius.sm),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ElectrodomesticoDetailScreen(id: e.id))),
              child: Padding(
                padding: const EdgeInsets.all(LumioSpace.s3),
                child: Row(
                  children: [
                    Icon(Icons.verified_outlined, size: 20, color: context.colors.warningText),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        proximas.length == 1
                            ? 'La garantía de "${e.nombre}" caduca en $dias días.'
                            : 'La garantía de "${e.nombre}" y ${proximas.length - 1} más caduca pronto.',
                        style: TextStyle(color: context.colors.warningText, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: context.colors.warningText, size: 18),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Tarjeta de acción con botón explícito a ancho completo -- vuelta al
/// diseño anterior a las tarjetas compactas lado a lado: con dos acciones
/// nada más, el botón visible rinde mejor que fiarlo todo al área táctil
/// de la tarjeta entera.
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

/// Tarjeta compacta para el carrusel horizontal de "Tus electrodomésticos".
class _TarjetaElectrodomesticoCompacta extends StatelessWidget {
  const _TarjetaElectrodomesticoCompacta({required this.electrodomestico});
  final Electrodomestico electrodomestico;

  @override
  Widget build(BuildContext context) {
    final acento = colorCategoria(context, electrodomestico.categoria);
    return SizedBox(
      width: 92,
      child: Material(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(LumioRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(LumioRadius.md),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ElectrodomesticoDetailScreen(id: electrodomestico.id))),
          child: Padding(
            padding: const EdgeInsets.all(LumioSpace.s2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: acento.withValues(alpha: 0.15),
                  backgroundImage: electrodomestico.fotoUrl != null ? NetworkImage(electrodomestico.fotoUrl!) : null,
                  child: electrodomestico.fotoUrl == null ? Icon(iconoCategoria(electrodomestico.categoria.icono), color: acento) : null,
                ),
                const SizedBox(height: LumioSpace.s1),
                Text(electrodomestico.nombre, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
