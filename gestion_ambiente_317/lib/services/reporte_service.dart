import 'package:supabase_flutter/supabase_flutter.dart';

class ReporteService {
  final _supabase = Supabase.instance.client;

  // 1. Stream en tiempo real para el Historial (ordenado de más reciente a más antiguo)
  Stream<List<Map<String, dynamic>>> getReportesStream() {
    return _supabase
        .from('reportes_fallas')
        .stream(primaryKey: ['id'])
        .order('id', ascending: false);
  }

  // 2. Stream para obtener la relación con la tabla de equipos
  Stream<List<Map<String, dynamic>>> getEquiposMapStream() {
    return _supabase.from('equipos').stream(primaryKey: ['id']);
  }

  // 3. Eliminar un reporte del historial (petición del profesor)
  Future<void> eliminarReporte(dynamic reporteId) async {
    await _supabase
        .from('reportes_fallas')
        .delete()
        .eq('id', reporteId);
  }

  // 4. Cambiar manualmente el estado de un reporte (PENDIENTE / RESUELTO)
  Future<void> cambiarEstadoReporte(dynamic reporteId, String nuevoEstado) async {
    await _supabase
        .from('reportes_fallas')
        .update({'estado_reporte': nuevoEstado})
        .eq('id', reporteId);
  }
}