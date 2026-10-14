// lib/screens/explorar_tab.dart
import 'package:flutter/material.dart';

import '../data/catalogo_lecciones.dart';
import '../models/electrodomestico.dart';
import '../services/leccion_service.dart';
import '../theme/design_tokens.dart';
import '../widgets/empty_state.dart';
import 'leccion_screen.dart';

class ExplorarTab extends StatefulWidget {
  const ExplorarTab({super.key});

  @override
  State<ExplorarTab> createState() => _ExplorarTabState();
}

class _ExplorarTabState extends State<ExplorarTab> {
  String _busqueda = '';
  CategoriaElectrodomestico? _categoria;

  @override
  Widget build(BuildContext context) {
    var lecciones = catalogoLecciones;
    if (_categoria != null) lecciones = lecciones.where((l) => l.categoria == _categoria).toList();
    if (_busqueda.isNotEmpty) lecciones = lecciones.where((l) => l.titulo.toLowerCase().contains(_busqueda.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Explorar')),
      body: Padding(
        padding: const EdgeInsets.all(LumioSpace.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(hintText: 'Buscar una lección...', prefixIcon: Icon(Icons.search)),
              onChanged: (v) => setState(() => _busqueda = v),
            ),
            const SizedBox(height: LumioSpace.s4),
            if (_categoria == null && _busqueda.isEmpty) ...[
              Text('¿Qué quieres aprender hoy?', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: LumioSpace.s3),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: LumioSpace.s3,
                crossAxisSpacing: LumioSpace.s3,
                childAspectRatio: 2.4,
                children: CategoriaElectrodomestico.values
                    .where((c) => c != CategoriaElectrodomestico.otro)
                    .map((c) => _TarjetaCategoria(categoria: c, onTap: () => setState(() => _categoria = c)))
                    .toList(),
              ),
              const SizedBox(height: LumioSpace.s4),
            ] else ...[
              Row(
                children: [
                  if (_categoria != null)
                    InputChip(
                      label: Text(_categoria!.etiqueta),
                      onDeleted: () => setState(() => _categoria = null),
                      avatar: Icon(_iconoPara(_categoria!.icono), size: 16, color: context.colors.brand),
                    ),
                ],
              ),
              const SizedBox(height: LumioSpace.s3),
            ],
            Expanded(
              child: lecciones.isEmpty
                  ? const EmptyState(icon: Icons.menu_book_outlined, title: 'Sin resultados', description: 'Prueba a cambiar la categoría o la búsqueda.')
                  : ListView.builder(
                      itemCount: lecciones.length,
                      itemBuilder: (context, i) {
                        final l = lecciones[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(Icons.auto_stories_outlined, color: context.colors.brand),
                            title: Text(l.titulo),
                            subtitle: Text(l.objetivo, maxLines: 2, overflow: TextOverflow.ellipsis),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              final progresoId = await LeccionService.iniciarOContinuar(l.id);
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
        ),
      ),
    );
  }
}

IconData _iconoPara(IconIdentificador i) => switch (i) {
      IconIdentificador.lavadora => Icons.local_laundry_service_outlined,
      IconIdentificador.lavavajillas => Icons.countertops_outlined,
      IconIdentificador.frigorifico => Icons.kitchen_outlined,
      IconIdentificador.horno => Icons.microwave_outlined,
      IconIdentificador.aire => Icons.ac_unit_outlined,
      IconIdentificador.pequeno => Icons.blender_outlined,
      IconIdentificador.otro => Icons.devices_other_outlined,
    };

class _TarjetaCategoria extends StatelessWidget {
  const _TarjetaCategoria({required this.categoria, required this.onTap});
  final CategoriaElectrodomestico categoria;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(LumioRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(LumioRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(LumioSpace.s3),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(LumioRadius.md), border: Border.all(color: context.colors.surfaceSunken)),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: context.colors.brandTint, borderRadius: BorderRadius.circular(LumioRadius.xs)),
                child: Icon(_iconoPara(categoria.icono), size: 18, color: context.colors.brand),
              ),
              const SizedBox(width: LumioSpace.s2),
              Expanded(
                child: Text(categoria.etiqueta, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
