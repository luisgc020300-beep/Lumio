// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LumioSpace.s6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.lightbulb_outline, size: 56, color: context.colors.brand),
              const SizedBox(height: LumioSpace.s5),
              Text('Entiende los aparatos\nde tu hogar.', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: LumioSpace.s3),
              Text(
                'Aprende a utilizarlos, descubre cómo funcionan y recibe ayuda cuando algo falla.',
                style: TextStyle(color: context.colors.inkMuted, fontSize: 15),
              ),
              const SizedBox(height: LumioSpace.s8),
              const _TarjetaCapacidad(icon: Icons.school_outlined, texto: 'Aprende cómo funcionan las cosas'),
              const SizedBox(height: LumioSpace.s3),
              const _TarjetaCapacidad(icon: Icons.photo_camera_outlined, texto: 'Descubre cómo utilizarlas'),
              const SizedBox(height: LumioSpace.s3),
              const _TarjetaCapacidad(icon: Icons.build_outlined, texto: 'Resuelve problemas paso a paso'),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text('Empezar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaCapacidad extends StatelessWidget {
  const _TarjetaCapacidad({required this.icon, required this.texto});
  final IconData icon;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LumioSpace.s4),
      decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(LumioRadius.md), border: Border.all(color: context.colors.surfaceSunken)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: context.colors.brandTint, borderRadius: BorderRadius.circular(LumioRadius.sm)),
            child: Icon(icon, color: context.colors.brand, size: 20),
          ),
          const SizedBox(width: LumioSpace.s3),
          Expanded(child: Text(texto, style: TextStyle(fontWeight: FontWeight.w600, color: context.colors.ink))),
        ],
      ),
    );
  }
}
