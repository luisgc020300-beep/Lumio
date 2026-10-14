// lib/screens/mis_electrodomesticos_tab.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/electrodomestico.dart';
import '../services/electrodomestico_service.dart';
import '../theme/design_tokens.dart';
import '../widgets/empty_state.dart';
import 'camara_screen.dart';
import 'electrodomestico_detail_screen.dart';

class MisElectrodomesticosTab extends StatelessWidget {
  const MisElectrodomesticosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi hogar')),
      body: StreamBuilder<List<Electrodomestico>>(
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
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: e.fotoUrl != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(LumioRadius.xs), child: CachedNetworkImage(imageUrl: e.fotoUrl!, width: 48, height: 48, fit: BoxFit.cover))
                      : CircleAvatar(backgroundColor: context.colors.brandTint, child: Icon(Icons.kitchen_outlined, color: context.colors.brand)),
                  title: Text(e.nombre),
                  subtitle: Text(e.modeloVerificado ? '${e.fabricante ?? ''} ${e.modelo ?? ''}'.trim() : e.categoria.etiqueta),
                  trailing: e.createdAt != null ? Text(DateFormat('d MMM', 'es_ES').format(e.createdAt!), style: TextStyle(fontSize: 11, color: context.colors.inkMuted)) : null,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ElectrodomesticoDetailScreen(id: e.id))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
