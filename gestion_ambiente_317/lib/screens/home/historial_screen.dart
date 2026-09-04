import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  SupabaseClient get supabase => Supabase.instance.client;

  String _filtroEstado = 'TODOS'; // 'TODOS', 'SOLUCIONADO', 'PENDIENTE'

  Future<List<Map<String, dynamic>>> _obtenerHistorial() async {
    // 1. Obtener novedades
    final novedadesResponse = await supabase
        .from('novedades')
        .select()
        .order('created_at', ascending: false);

    // 2. Obtener nombres de los equipos
    final equiposResponse = await supabase
        .from('equipos')
        .select('id, nombre');

    final Map<int, String> mapaEquipos = {
      for (var e in List<Map<String, dynamic>>.from(equiposResponse))
        e['id'] as int: e['nombre'].toString()
    };

    // 3. Mapear y unir los datos
    return List<Map<String, dynamic>>.from(novedadesResponse).map((novedad) {
      final int? equipoId = novedad['equipo_id'];
      return {
        ...novedad,
        'nombre_equipo': mapaEquipos[equipoId] ?? 'Equipo #$equipoId',
      };
    }).toList();
  }

  Future<void> _eliminarNovedad(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar registro?'),
        content: const Text('Esta acción borrará el registro del historial permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await supabase.from('novedades').delete().eq('id', id);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Historial de Novedades',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D3B66),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de Filtros
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFiltroChip('TODOS'),
                _buildFiltroChip('SOLUCIONADO'),
                _buildFiltroChip('PENDIENTE'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lista Principal
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _obtenerHistorial(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar historial: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                var novedades = snapshot.data ?? [];

                // Filtrado por estado
                if (_filtroEstado != 'TODOS') {
                  novedades = novedades
                      .where((item) => item['estado'] == _filtroEstado)
                      .toList();
                }

                if (novedades.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay registros en estado "$_filtroEstado"',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: novedades.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = novedades[index];
                    final bool esPendiente = item['estado'] == 'PENDIENTE';
                    final String nombreEquipo = item['nombre_equipo'] ?? '';

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: esPendiente ? const Color(0xFFFFF5F5) : const Color(0xFFF4FBF7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: esPendiente ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: esPendiente ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                                child: Icon(
                                  esPendiente ? Icons.warning_amber_rounded : Icons.check,
                                  color: esPendiente ? Colors.orange.shade800 : Colors.green.shade700,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  nombreEquipo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF0D3B66),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: esPendiente ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  esPendiente ? 'PENDIENTE' : 'SOLUCIONADO',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () => _eliminarNovedad(item['id']),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(item['descripcion'] ?? ''),
                          const SizedBox(height: 8),
                          Text(
                            'Gravedad: ${item['gravedad'] ?? 'NINGUNA'}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: esPendiente ? Colors.red.shade800 : Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroChip(String titulo) {
    final bool seleccionado = _filtroEstado == titulo;
    return InkWell(
      onTap: () => setState(() => _filtroEstado = titulo),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFF0D3B66) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? const Color(0xFF0D3B66) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          titulo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: seleccionado ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}