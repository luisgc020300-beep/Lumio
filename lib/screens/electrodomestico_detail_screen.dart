// lib/screens/electrodomestico_detail_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/catalogo_lecciones.dart';
import '../models/diagnostico.dart';
import '../models/electrodomestico.dart';
import '../services/diagnostico_service.dart';
import '../services/electrodomestico_service.dart';
import '../services/leccion_service.dart';
import '../theme/categoria_estilos.dart';
import '../theme/design_tokens.dart';
import '../widgets/empty_state.dart';
import 'diagnostico_screen.dart';
import 'leccion_screen.dart';

class ElectrodomesticoDetailScreen extends StatelessWidget {
  const ElectrodomesticoDetailScreen({required this.id, super.key});
  final String id;

  Future<void> _renombrar(BuildContext context, Electrodomestico e) async {
    final ctrl = TextEditingController(text: e.nombre);
    final nuevo = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Renombrar'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(context).pop(ctrl.text.trim()), child: const Text('Guardar')),
        ],
      ),
    );
    if (nuevo != null && nuevo.isNotEmpty) await ElectrodomesticoService.renombrar(e.id, nuevo);
  }

  Future<void> _eliminar(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar este electrodoméstico?'),
        content: const Text('Se eliminará su foto y la información guardada. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar != true) return;
    await ElectrodomesticoService.eliminar(id);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Electrodomestico?>(
      stream: ElectrodomesticoService.streamElectrodomestico(id),
      builder: (context, snapshot) {
        final e = snapshot.data;
        if (e == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(e.nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
              actions: [
                IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _renombrar(context, e)),
                IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _eliminar(context)),
              ],
              bottom: const TabBar(tabs: [Tab(text: 'Resumen'), Tab(text: 'Aprender'), Tab(text: 'Historial')]),
            ),
            body: TabBarView(
              children: [
                _TabResumen(e: e),
                _TabAprender(e: e),
                _TabHistorial(e: e),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TabResumen extends StatelessWidget {
  const _TabResumen({required this.e});
  final Electrodomestico e;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(LumioSpace.s4),
      children: [
        if (e.fotoUrl != null) ClipRRect(borderRadius: BorderRadius.circular(LumioRadius.lg), child: CachedNetworkImage(imageUrl: e.fotoUrl!, height: 200, width: double.infinity, fit: BoxFit.cover)),
        const SizedBox(height: LumioSpace.s4),
        Row(children: [
          Chip(
            avatar: Icon(iconoCategoria(e.categoria.icono), size: 16, color: colorCategoria(context, e.categoria)),
            label: Text(e.categoria.etiqueta),
            backgroundColor: colorCategoria(context, e.categoria).withValues(alpha: 0.12),
          ),
          const SizedBox(width: 6),
          Chip(
            label: Text(e.modeloVerificado ? 'Modelo verificado' : 'Identificación general'),
            backgroundColor: e.modeloVerificado ? context.colors.success.withValues(alpha: 0.15) : context.colors.warning.withValues(alpha: 0.15),
          ),
        ]),
        if (e.fabricante != null || e.modelo != null) ...[
          const SizedBox(height: LumioSpace.s3),
          Text('${e.fabricante ?? ''} ${e.modelo ?? ''}'.trim(), style: Theme.of(context).textTheme.titleMedium),
        ],
        if (e.controlesVisibles.isNotEmpty) ...[
          const SizedBox(height: LumioSpace.s5),
          Text('Controles reconocidos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          ...e.controlesVisibles.map((c) => Row(children: [const Icon(Icons.tune, size: 16), const SizedBox(width: 6), Expanded(child: Text(c))])),
        ],
        if (!e.modeloVerificado) ...[
          const SizedBox(height: LumioSpace.s5),
          Container(
            padding: const EdgeInsets.all(LumioSpace.s3),
            decoration: BoxDecoration(color: context.colors.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(LumioRadius.sm)),
            child: Row(children: [
              Icon(Icons.info_outline, size: 18, color: context.colors.warningText),
              const SizedBox(width: 8),
              Expanded(child: Text('No se verificó el fabricante/modelo exactos. Puedes seguir aprendiendo con el contenido general de esta categoría.', style: TextStyle(color: context.colors.warningText))),
            ]),
          ),
        ],
      ],
    );
  }
}

class _TabAprender extends StatelessWidget {
  const _TabAprender({required this.e});
  final Electrodomestico e;

  @override
  Widget build(BuildContext context) {
    final lecciones = leccionesPorCategoria(e.categoria);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(LumioSpace.s4),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DiagnosticoScreen(electrodomesticoId: e.id))),
              icon: const Icon(Icons.build_outlined),
              label: const Text('Tengo un problema con este aparato'),
            ),
          ),
        ),
        Expanded(
          child: lecciones.isEmpty
              ? const EmptyState(icon: Icons.menu_book_outlined, title: 'Sin lecciones todavía para esta categoría', description: 'Estamos ampliando el catálogo poco a poco.')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: LumioSpace.s4),
                  itemCount: lecciones.length,
                  itemBuilder: (context, i) {
                    final l = lecciones[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(Icons.auto_stories_outlined, color: context.colors.brand),
                        title: Text(l.titulo),
                        subtitle: Text(l.objetivo, maxLines: 2, overflow: TextOverflow.ellipsis),
                        onTap: () async {
                          final progresoId = await LeccionService.iniciarOContinuar(l.id, electrodomesticoId: e.id);
                          if (context.mounted) {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => LeccionScreen(leccion: l, progresoId: progresoId)));
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TabHistorial extends StatelessWidget {
  const _TabHistorial({required this.e});
  final Electrodomestico e;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SesionDiagnostico>>(
      stream: DiagnosticoService.streamSesiones(),
      builder: (context, snapshot) {
        final sesiones = (snapshot.data ?? []).where((s) => s.electrodomesticoId == e.id).toList();
        if (sesiones.isEmpty) {
          return const EmptyState(icon: Icons.history, title: 'Sin historial todavía', description: 'Aquí aparecerán tus sesiones de diagnóstico sobre este aparato.');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(LumioSpace.s4),
          itemCount: sesiones.length,
          itemBuilder: (context, i) {
            final s = sesiones[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.build_outlined),
                title: Text(s.sintoma, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(s.estado.etiqueta),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DiagnosticoScreen(sesionId: s.id, electrodomesticoId: e.id))),
              ),
            );
          },
        );
      },
    );
  }
}
