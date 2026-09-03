import 'package:flutter/material.dart';
import '../../services/reporte_service.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  Future<void> _eliminarReporte(
    BuildContext context,
    ReporteService reporteService,
    dynamic reporteId,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Novedad'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este registro del historial?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await reporteService.eliminarReporte(reporteId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reporte eliminado correctamente'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reporteService = ReporteService();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Historial de Novedades',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0D3B66),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // Usamos el Stream definido en ReporteService
        stream: reporteService.getReportesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar el historial: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final reportes = snapshot.data ?? [];

          if (reportes.isEmpty) {
            return const Center(
              child: Text(
                'No hay novedades registradas',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return StreamBuilder<List<Map<String, dynamic>>>(
            // Obtenemos los equipos a través del servicio
            stream: reporteService.getEquiposMapStream(),
            builder: (context, equiposSnapshot) {
              final equiposList = equiposSnapshot.data ?? [];
              final equiposMap = {
                for (var eq in equiposList) eq['id']: eq
              };

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reportes.length,
                itemBuilder: (context, index) {
                  final reporte = reportes[index];
                  final reporteId = reporte['id'];
                  final equipoId = reporte['equipo_id'];
                  final equipoInfo = equiposMap[equipoId];

                  final codigoEquipo = equipoInfo?['codigo'] ?? 'PC-$equipoId';
                  final estadoReporte = reporte['estado_reporte'] ?? 'PENDIENTE';
                  final gravedad = reporte['gravedad'] ?? 'NINGUNA';
                  final descripcion = reporte['descripcion'] ?? 'Sin detalle';

                  final esSolucionado = estadoReporte == 'RESUELTO' ||
                      estadoReporte == 'SOLUCIONADO' ||
                      gravedad == 'NINGUNA';

                  final colorCardBorder =
                      esSolucionado ? Colors.green.shade300 : Colors.red.shade300;
                  final colorCardBg = esSolucionado
                      ? Colors.green.shade50.withOpacity(0.5)
                      : Colors.red.shade50.withOpacity(0.5);
                  final colorBadgeBg =
                      esSolucionado ? Colors.green.shade600 : Colors.red.shade600;
                  final textoBadge = esSolucionado ? 'SOLUCIONADO' : 'PENDIENTE';
                  final icono = esSolucionado
                      ? Icons.check_circle_outline
                      : Icons.warning_amber_rounded;
                  final colorIcono =
                      esSolucionado ? Colors.green.shade700 : Colors.red.shade700;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorCardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorCardBorder, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: esSolucionado
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icono, color: colorIcono, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                codigoEquipo,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorBadgeBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                textoBadge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Botón de eliminar desacoplado a través del servicio
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent, size: 22),
                              onPressed: () =>
                                  _eliminarReporte(context, reporteService, reporteId),
                              tooltip: 'Eliminar del historial',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          descripcion,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Gravedad: $gravedad',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}