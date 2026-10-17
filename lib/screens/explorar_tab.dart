// lib/screens/explorar_tab.dart
import 'package:flutter/material.dart';

import '../data/busqueda_lecciones.dart';
import '../data/catalogo_lecciones.dart';
import '../models/electrodomestico.dart';
import '../theme/categoria_estilos.dart';
import '../theme/design_tokens.dart';
import '../widgets/empty_state.dart';
import 'leccion_screen.dart';

class ExplorarTab extends StatefulWidget {
  const ExplorarTab({super.key});

  @override
  State<ExplorarTab> createState() => _ExplorarTabState();
}

class _ExplorarTabState extends State<ExplorarTab> {
  final _controladorBusqueda = TextEditingController();
  String _busqueda = '';
  CategoriaElectrodomestico? _categoria;

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  void _elegirCategoriaDesdeSugerencia(CategoriaElectrodomestico c) {
    _controladorBusqueda.clear();
    setState(() {
      _categoria = c;
      _busqueda = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    var lecciones = catalogoLecciones;
    if (_categoria != null) lecciones = lecciones.where((l) => l.categoria == _categoria).toList();
    if (_busqueda.isNotEmpty) {
      final busquedaNormalizada = normalizarBusqueda(_busqueda);
      lecciones = lecciones.where((l) => leccionCoincideConBusqueda(l, busquedaNormalizada)).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Explorar')),
      // Un único scrollable para toda la pantalla -- incluida la rejilla de
      // categorías -- a propósito: así al bajar la rejilla se va con el
      // resto y las lecciones se quedan con toda la pantalla, en vez de
      // quedarse fija ocupando sitio permanentemente.
      body: ListView(
        padding: const EdgeInsets.all(LumioSpace.s4),
        children: [
          TextField(
            controller: _controladorBusqueda,
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
                    avatar: Icon(iconoCategoria(_categoria!.icono), size: 16, color: colorCategoria(context, _categoria!)),
                  ),
              ],
            ),
            const SizedBox(height: LumioSpace.s3),
          ],
          if (lecciones.isEmpty)
            EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'Sin resultados',
              description: _busqueda.isEmpty
                  ? 'Prueba a cambiar la categoría.'
                  : 'Todavía no tenemos una lección sobre "$_busqueda". Prueba con alguna de estas categorías:',
              action: _busqueda.isEmpty
                  ? null
                  : Wrap(
                      spacing: LumioSpace.s2,
                      runSpacing: LumioSpace.s2,
                      alignment: WrapAlignment.center,
                      children: CategoriaElectrodomestico.values
                          .where((c) => c != CategoriaElectrodomestico.otro)
                          .map((c) => ActionChip(
                                avatar: Icon(iconoCategoria(c.icono), size: 16, color: colorCategoria(context, c)),
                                label: Text(c.etiqueta),
                                onPressed: () => _elegirCategoriaDesdeSugerencia(c),
                              ))
                          .toList(),
                    ),
            )
          else
            for (final l in lecciones)
              Padding(
                padding: const EdgeInsets.only(bottom: LumioSpace.s3),
                child: TarjetaLeccionVisual(leccion: l, alturaIlustracion: 190),
              ),
        ],
      ),
    );
  }
}

class _TarjetaCategoria extends StatelessWidget {
  const _TarjetaCategoria({required this.categoria, required this.onTap});
  final CategoriaElectrodomestico categoria;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final acento = colorCategoria(context, categoria);
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(LumioRadius.md),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(LumioRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(LumioSpace.s3),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(LumioRadius.md),
            boxShadow: [BoxShadow(color: context.colors.ink.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: acento.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(LumioRadius.xs)),
                child: Icon(iconoCategoria(categoria.icono), size: 18, color: acento),
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
