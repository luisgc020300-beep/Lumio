// lib/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

/// Envoltorio fino sobre Firebase Analytics con la taxonomía mínima que
/// importa para saber si las mejoras de diferenciación/retención (ver
/// plan "LUMIO — diferenciación real y retención") sirven de algo. Sin
/// fotos, sin texto libre del usuario ni PII como parámetro -- solo lo
/// justo para medir el embudo.
class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> electrodomesticoGuardado({required String categoria, required bool modeloVerificado}) {
    return _analytics.logEvent(name: 'electrodomestico_guardado', parameters: {'categoria': categoria, 'modelo_verificado': modeloVerificado});
  }

  static Future<void> leccionIniciada({required String leccionId}) {
    return _analytics.logEvent(name: 'leccion_iniciada', parameters: {'leccion_id': leccionId});
  }

  static Future<void> leccionCompletada({required String leccionId}) {
    return _analytics.logEvent(name: 'leccion_completada', parameters: {'leccion_id': leccionId});
  }

  static Future<void> diagnosticoIniciado({required bool tieneElectrodomestico}) {
    return _analytics.logEvent(name: 'diagnostico_iniciado', parameters: {'tiene_electrodomestico': tieneElectrodomestico});
  }

  /// El evento clave para validar el diferenciador del Bloque 2: ¿la IA
  /// usó de verdad el historial previo del electrodoméstico?
  static Future<void> diagnosticoConHistorialPrevio() {
    return _analytics.logEvent(name: 'diagnostico_con_historial_previo');
  }

  static Future<void> avisoSeguridadMostrado() {
    return _analytics.logEvent(name: 'aviso_seguridad_mostrado');
  }

  static Future<void> garantiaBannerMostrado() {
    return _analytics.logEvent(name: 'garantia_banner_mostrado');
  }
}
