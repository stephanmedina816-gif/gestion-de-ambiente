import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/equipo_model.dart';

class EquipoService {
  final _supabase = Supabase.instance.client;

  // Stream en tiempo real para la pantalla principal
  Stream<List<EquipoModel>> getEquiposStream() {
    return _supabase
        .from('equipos')
        .stream(primaryKey: ['id'])
        .order('codigo', ascending: true)
        .map((data) => data.map((json) => EquipoModel.fromJson(json)).toList());
  }

  // Lógica de actualización de estado e historial
  Future<void> registrarReporteYActualizarEquipo({
    required String equipoId,
    required bool esOperativo,
    required String descripcion,
    required String gravedad,
  }) async {
    if (!esOperativo) {
      // 1. Crear el reporte en estado PENDIENTE
      await _supabase.from('reportes_fallas').insert({
        'equipo_id': equipoId,
        'descripcion': descripcion,
        'gravedad': gravedad,
        'estado_reporte': 'PENDIENTE',
      });
    } else {
      // 2. Marcar como RESUELTO el reporte pendiente de este equipo
      final actualizados = await _supabase
          .from('reportes_fallas')
          .update({'estado_reporte': 'RESUELTO'})
          .eq('equipo_id', equipoId)
          .eq('estado_reporte', 'PENDIENTE')
          .select();

      debugPrint('Filas actualizadas a RESUELTO: $actualizados');
    }

    // 3. Actualizar la tabla principal equipos
    await _supabase.from('equipos').update({
      'estado': esOperativo,
      'observacion': descripcion,
    }).eq('id', equipoId);
  }
}