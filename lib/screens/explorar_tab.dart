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
            const SizedBox(height: LumioSpace.s3),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _ChipCategoria(etiqueta: 'Todas', seleccionado: _categoria == null, onTap: () => setState(() => _categoria = null)),
                  ...CategoriaElectrodomestico.values.where((c) => c != CategoriaElectrodomestico.otro).map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: _ChipCategoria(etiqueta: c.etiqueta, seleccionado: _categoria == c, onTap: () => setState(() => _categoria = c)),
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: LumioSpace.s4),
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

class _ChipCategoria extends StatelessWidget {
  const _ChipCategoria({required this.etiqueta, required this.seleccionado, required this.onTap});
  final String etiqueta;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(label: Text(etiqueta), selected: seleccionado, onSelected: (_) => onTap());
  }
}
