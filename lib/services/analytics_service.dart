// lib/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Seam mínimo de solo test: deja sustituir a dónde van los eventos sin
/// que ningún llamador de producción note la diferencia -- sin esto,
/// cualquier test que ejercite un camino con una llamada "fire-and-forget"
/// a AnalyticsService (p. ej. LeccionService.iniciarOContinuar) deja una
/// excepción sin gestionar porque Firebase no está inicializado en tests.
abstract class AnalyticsSink {
  Future<void> logEvent({required String name, Map<String, Object>? parameters});
}

class _FirebaseAnalyticsSink implements AnalyticsSink {
  const _FirebaseAnalyticsSink();
  @override
  Future<void> logEvent({required String name, Map<String, Object>? parameters}) {
    return FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);
  }
}

/// Envoltorio fino sobre Firebase Analytics con la taxonomía mínima que
/// importa para saber si las mejoras de diferenciación/retención (ver
/// plan "LUMIO — diferenciación real y retención") sirven de algo. Sin
/// fotos, sin texto libre del usuario ni PII como parámetro -- solo lo
/// justo para medir el embudo.
class AnalyticsService {
  AnalyticsService._();

  @visibleForTesting
  static AnalyticsSink sink = const _FirebaseAnalyticsSink();

  static Future<void> electrodomesticoGuardado({required String categoria, required bool modeloVerificado}) {
    return sink.logEvent(name: 'electrodomestico_guardado', parameters: {'categoria': categoria, 'modelo_verificado': modeloVerificado});
  }

  static Future<void> leccionIniciada({required String leccionId}) {
    return sink.logEvent(name: 'leccion_iniciada', parameters: {'leccion_id': leccionId});
  }

  static Future<void> leccionCompletada({required String leccionId}) {
    return sink.logEvent(name: 'leccion_completada', parameters: {'leccion_id': leccionId});
  }

  static Future<void> diagnosticoIniciado({required bool tieneElectrodomestico}) {
    return sink.logEvent(name: 'diagnostico_iniciado', parameters: {'tiene_electrodomestico': tieneElectrodomestico});
  }

  /// El evento clave para validar el diferenciador del Bloque 2: ¿la IA
  /// usó de verdad el historial previo del electrodoméstico?
  static Future<void> diagnosticoConHistorialPrevio() {
    return sink.logEvent(name: 'diagnostico_con_historial_previo');
  }

  static Future<void> avisoSeguridadMostrado() {
    return sink.logEvent(name: 'aviso_seguridad_mostrado');
  }

  static Future<void> garantiaBannerMostrado() {
    return sink.logEvent(name: 'garantia_banner_mostrado');
  }
}
