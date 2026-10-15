// lib/screens/mis_electrodomesticos_tab.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/catalogo_lecciones.dart';
import '../models/electrodomestico.dart';
import '../models/leccion.dart';
import '../services/electrodomestico_service.dart';
import '../services/leccion_service.dart';
import '../theme/categoria_estilos.dart';
import '../theme/design_tokens.dart';
import '../widgets/empty_state.dart';
import 'camara_screen.dart';
import 'electrodomestico_detail_screen.dart';
import 'leccion_screen.dart';

class MisElectrodomesticosTab extends StatelessWidget {
  const MisElectrodomesticosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi hogar'),
          bottom: const TabBar(tabs: [Tab(text: 'Mis aparatos'), Tab(text: 'Mis aprendizajes')]),
        ),
        body: const TabBarView(children: [_TabAparatos(), _TabAprendizajes()]),
      ),
    );
  }
}

class _TabAparatos extends StatelessWidget {
  const _TabAparatos();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Electrodomestico>>(
      stream: ElectrodomesticoService.streamElectrodomesticos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.kitchen_outlined,
            title: 'Todavía no has guardado ningún electrodoméstico',
            description: 'Haz una foto para que Lumio lo identifique y empieces a aprender sobre él.',
            action: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CamaraScreen())),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Hacer una foto'),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(LumioSpace.s4),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final e = items[i];
            final acento = colorCategoria(context, e.categoria);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: e.fotoUrl != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(LumioRadius.xs), child: CachedNetworkImage(imageUrl: e.fotoUrl!, width: 48, height: 48, fit: BoxFit.cover))
                    : CircleAvatar(backgroundColor: acento.withValues(alpha: 0.15), child: Icon(iconoCategoria(e.categoria.icono), color: acento)),
                title: Text(e.nombre),
                subtitle: Text(e.modeloVerificado ? '${e.fabricante ?? ''} ${e.modelo ?? ''}'.trim() : e.categoria.etiqueta),
                trailing: e.createdAt != null ? Text(DateFormat('d MMM', 'es_ES').format(e.createdAt!), style: TextStyle(fontSize: 11, color: context.colors.inkMuted)) : null,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ElectrodomesticoDetailScreen(id: e.id))),
              ),
            );
          },
        );
      },
    );
  }
}

class _TabAprendizajes extends StatelessWidget {
  const _TabAprendizajes();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProgresoLeccion>>(
      stream: LeccionService.streamProgreso(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final progresos = snapshot.data!.map((p) => (progreso: p, leccion: leccionPorId(p.leccionId))).where((r) => r.leccion != null).toList();
        if (progresos.isEmpty) {
          return const EmptyState(
            icon: Icons.auto_stories_outlined,
            title: 'Todavía no has empezado ninguna lección',
            description: 'Ve a Explorar para elegir qué quieres aprender.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(LumioSpace.s4),
          itemCount: progresos.length,
          itemBuilder: (context, i) {
            final r = progresos[i];
            final leccion = r.leccion!;
            final completada = r.progreso.estado == EstadoProgresoLeccion.completada;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  completada ? Icons.check_circle_outline : Icons.auto_stories_outlined,
                  color: completada ? context.colors.success : context.colors.brand,
                ),
                title: Text(leccion.titulo),
                subtitle: Text(completada ? 'Completada' : 'Paso ${r.progreso.pasoActual + 1} de ${leccion.pasos.length}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LeccionScreen(leccion: leccion, progresoId: r.progreso.id, pasoInicial: r.progreso.pasoActual))),
              ),
            );
          },
        );
      },
    );
  }
}
