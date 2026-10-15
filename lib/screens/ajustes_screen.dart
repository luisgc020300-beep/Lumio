// lib/screens/ajustes_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/leccion.dart';
import '../services/leccion_service.dart';
import '../theme/design_tokens.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_error.dart';
import '../widgets/ios_list.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  bool _cerrandoSesion = false;
  bool _eliminando = false;

  Future<void> _cerrarSesion() async {
    setState(() => _cerrandoSesion = true);
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (mounted) AppError.show(context, 'No se ha podido cerrar sesión.', error: e);
    } finally {
      if (mounted) setState(() => _cerrandoSesion = false);
    }
  }

  Future<void> _eliminarCuenta() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar cuenta?'),
        content: const Text('Esto elimina tu cuenta de acceso de forma permanente.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar != true) return;
    setState(() => _eliminando = true);
    try {
      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        AppError.show(context, e.code == 'requires-recent-login' ? 'Por seguridad, vuelve a iniciar sesión y repite esta acción.' : 'No se ha podido eliminar la cuenta.', error: e);
      }
    } finally {
      if (mounted) setState(() => _eliminando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final controller = ThemeController.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(LumioSpace.s4),
            children: [
              IosSection(
                header: 'Cuenta',
                rows: [IosRow(icon: Icons.mail_outline, iconColor: context.colors.brand, title: email, subtitle: 'Correo de acceso', showChevron: false)],
              ),
              IosSection(
                header: 'Tu aprendizaje',
                rows: [
                  StreamBuilder<List<ProgresoLeccion>>(
                    stream: LeccionService.streamProgreso(),
                    builder: (context, snapshot) {
                      final progreso = snapshot.data ?? [];
                      final completadas = progreso.where((p) => p.estado == EstadoProgresoLeccion.completada).length;
                      return IosRow(
                        icon: Icons.emoji_events_outlined,
                        iconColor: context.colors.success,
                        title: 'Lecciones completadas',
                        subtitle: 'Basado en tu progreso real guardado',
                        trailing: Text('$completadas', style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.ink)),
                        showChevron: false,
                      );
                    },
                  ),
                ],
              ),
              IosSection(
                header: 'Apariencia',
                footer: 'Elige cómo se ve Lumio en este dispositivo.',
                rows: [
                  IosRow(
                    icon: Icons.light_mode_outlined,
                    iconColor: context.colors.warning,
                    title: 'Claro',
                    selected: controller.mode == ThemeMode.light,
                    trailing: controller.mode == ThemeMode.light ? Icon(Icons.check, color: context.colors.brand) : null,
                    showChevron: false,
                    onTap: () => controller.setMode(ThemeMode.light),
                  ),
                  IosRow(
                    icon: Icons.dark_mode_outlined,
                    iconColor: context.colors.lavanda,
                    title: 'Oscuro',
                    selected: controller.mode == ThemeMode.dark,
                    trailing: controller.mode == ThemeMode.dark ? Icon(Icons.check, color: context.colors.brand) : null,
                    showChevron: false,
                    onTap: () => controller.setMode(ThemeMode.dark),
                  ),
                  IosRow(
                    icon: Icons.phone_iphone,
                    iconColor: context.colors.inkMuted,
                    title: 'Sistema',
                    selected: controller.mode == ThemeMode.system,
                    trailing: controller.mode == ThemeMode.system ? Icon(Icons.check, color: context.colors.brand) : null,
                    showChevron: false,
                    onTap: () => controller.setMode(ThemeMode.system),
                  ),
                ],
              ),
              IosSection(
                header: 'Sesión',
                rows: [
                  IosRow(
                    icon: Icons.logout,
                    iconColor: context.colors.inkMuted,
                    title: _cerrandoSesion ? 'Cerrando sesión...' : 'Cerrar sesión',
                    onTap: _cerrandoSesion ? null : _cerrarSesion,
                    showChevron: false,
                  ),
                  IosRow(
                    icon: Icons.delete_outline,
                    iconColor: context.colors.error,
                    titleColor: context.colors.errorText,
                    title: _eliminando ? 'Eliminando...' : 'Eliminar cuenta',
                    onTap: _eliminando ? null : _eliminarCuenta,
                    showChevron: false,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
