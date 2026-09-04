import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetalleEquipoScreen extends StatefulWidget {
  final Map<String, dynamic> equipo;

  const DetalleEquipoScreen({super.key, required this.equipo});

  @override
  State<DetalleEquipoScreen> createState() => _DetalleEquipoScreenState();
}

class _DetalleEquipoScreenState extends State<DetalleEquipoScreen> {
  SupabaseClient get supabase => Supabase.instance.client;
  late Map<String, dynamic> _equipoActual;

  @override
  void initState() {
    super.initState();
    _equipoActual = widget.equipo;
  }

  Future<List<Map<String, dynamic>>> _obtenerNovedades() async {
    final response = await supabase
        .from('novedades')
        .select()
        .eq('equipo_id', _equipoActual['id'])
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _sincronizarEstadoEquipo() async {
    final pendientes = await supabase
        .from('novedades')
        .select('id')
        .eq('equipo_id', _equipoActual['id'])
        .eq('estado', 'PENDIENTE');

    final bool nuevoEstadoOperativo = pendientes.isEmpty;

    await supabase
        .from('equipos')
        .update({'es_operativo': nuevoEstadoOperativo})
        .eq('id', _equipoActual['id']);

    if (!mounted) return;
    setState(() {
      _equipoActual['es_operativo'] = nuevoEstadoOperativo;
    });
  }

  void _mostrarDialogoReporte() {
    final controller = TextEditingController();
    String gravedadSeleccionada = 'ALTA';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Reportar Novedad - ${_equipoActual['nombre']}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Describe el fallo encontrado...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Gravedad:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: gravedadSeleccionada,
                    isExpanded: true,
                    items: ['ALTA', 'MEDIA', 'BAJA'].map((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => gravedadSeleccionada = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D3B66),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;

                    final navigator = Navigator.of(dialogContext);

                    // 1. Insertar novedad
                    await supabase.from('novedades').insert({
                      'equipo_id': _equipoActual['id'],
                      'descripcion': controller.text.trim(),
                      'gravedad': gravedadSeleccionada,
                      'estado': 'PENDIENTE',
                    });

                    // 2. Marcar equipo con falla
                    await _sincronizarEstadoEquipo();

                    navigator.pop();
                  },
                  child: const Text('Guardar Reporte'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _marcarResuelto(int novedadId) async {
    await supabase
        .from('novedades')
        .update({'estado': 'SOLUCIONADO', 'gravedad': 'NINGUNA'})
        .eq('id', novedadId);

    await _sincronizarEstadoEquipo();
  }

  Future<void> _eliminarNovedad(int novedadId) async {
    await supabase.from('novedades').delete().eq('id', novedadId);
    await _sincronizarEstadoEquipo();
  }

  @override
  Widget build(BuildContext context) {
    final bool esOperativo = _equipoActual['es_operativo'] ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(_equipoActual['nombre'] ?? 'Detalle Equipo'),
        backgroundColor: const Color(0xFF0D3B66),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Banner Superior
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: esOperativo ? const Color(0xFFEFF8F1) : const Color(0xFFFDE8E8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: esOperativo ? const Color(0xFFC8E6C9) : const Color(0xFFFCA5A5),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.laptop_chromebook,
                      color: esOperativo ? Colors.green.shade700 : Colors.red.shade700,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _equipoActual['nombre'] ?? 'PC-317',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            esOperativo ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                            size: 16,
                            color: esOperativo ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            esOperativo ? 'Operativo' : 'Con Falla',
                            style: TextStyle(
                              color: esOperativo ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Ambiente 317 - ADSO',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Botón Reportar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D3B66),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _mostrarDialogoReporte,
                icon: const Icon(Icons.add),
                label: const Text('Reportar Novedad', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),

            // Lista de Novedades del Equipo
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _obtenerNovedades(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final novedades = snapshot.data ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Novedades (${novedades.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (novedades.isEmpty)
                      const Text(
                        'No hay novedades registradas para este equipo.',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: novedades.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = novedades[index];
                          final bool esPendiente = item['estado'] == 'PENDIENTE';

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
                                    Icon(
                                      esPendiente ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                                      color: esPendiente ? Colors.orange.shade800 : Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _equipoActual['nombre'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: esPendiente ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item['estado'] ?? '',
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () => _eliminarNovedad(item['id']),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(item['descripcion'] ?? ''),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Gravedad: ${item['gravedad'] ?? 'NINGUNA'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: esPendiente ? Colors.red.shade800 : Colors.blue.shade900,
                                      ),
                                    ),
                                    if (esPendiente)
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF22C55E),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        ),
                                        onPressed: () => _marcarResuelto(item['id']),
                                        child: const Text('Marcar resuelto', style: TextStyle(fontSize: 12)),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}