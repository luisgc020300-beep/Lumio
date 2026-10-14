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
              const SizedBox(height: LumioSpace.s4),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: context.colors.brand, borderRadius: BorderRadius.circular(LumioRadius.sm)),
                    child: Icon(Icons.home_outlined, color: context.colors.brandOn, size: 26),
                  ),
                  const SizedBox(width: LumioSpace.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tu hogar, más fácil', style: Theme.of(context).textTheme.headlineSmall),
                        Text(
                          'Entiende · Usa · Resuelve · Aprende',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.brand, letterSpacing: 0.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(color: context.colors.brandTint, shape: BoxShape.circle),
                  child: Icon(Icons.kitchen_outlined, size: 108, color: context.colors.brand),
                ),
              ),
              const SizedBox(height: LumioSpace.s8),
              Text('Tu hogar, más fácil', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: LumioSpace.s3),
              Text(
                'Aprende a usar, entender y resolver con tus electrodomésticos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.inkMuted, fontSize: 15),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen(registroInicial: true))),
                child: const Text('Crear cuenta'),
              ),
              const SizedBox(height: LumioSpace.s3),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text('Iniciar sesión'),
              ),
              const SizedBox(height: LumioSpace.s4),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: Text('¿Tienes una cuenta? Inicia sesión', style: TextStyle(color: context.colors.inkMuted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
