import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NuevaNovedadScreen extends StatefulWidget {
  final int equipoId;
  final String nombreEquipo;

  const NuevaNovedadScreen({
    super.key,
    required this.equipoId,
    required this.nombreEquipo,
  });

  @override
  State<NuevaNovedadScreen> createState() => _NuevaNovedadScreenState();
}

class _NuevaNovedadScreenState extends State<NuevaNovedadScreen> {
  final _descripcionController = TextEditingController();
  String _gravedadSeleccionada = 'NINGUNA';
  bool _cargando = false;

  final List<String> _nivelesGravedad = ['NINGUNA', 'BAJA', 'MEDIA', 'ALTA'];

  Future<void> _guardarNovedad() async {
    final descripcion = _descripcionController.text.trim();
    if (descripcion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor describe el problema detectado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final supabase = Supabase.instance.client;

      // 1. Insertar el reporte en estado PENDIENTE
      await supabase.from('novedades').insert({
        'equipo_id': widget.equipoId,
        'descripcion': descripcion,
        'gravedad': _gravedadSeleccionada,
        'estado': 'PENDIENTE',
      });

      // 2. Deshabilitar el equipo (Con Falla)
      await supabase.from('equipos').update({
        'es_operativo': false,
      }).eq('id', widget.equipoId);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar reporte: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Nueva Novedad',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D3B66),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner informativo del equipo objetivo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFEBF3FA),
                    child: Icon(
                      Icons.laptop_chromebook,
                      color: Color(0xFF0D3B66),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.nombreEquipo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF0D3B66),
                        ),
                      ),
                      const Text(
                        'Ambiente 317 - ADSO',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Campo de entrada de descripción
            const Text(
              'Descripción del problema',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF0D3B66),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descripcionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describa el problema detectado...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Selector de Nivel de Gravedad
            const Text(
              'Nivel de Gravedad',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF0D3B66),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _nivelesGravedad.length,
              itemBuilder: (context, index) {
                final nivel = _nivelesGravedad[index];
                final bool seleccionado = _gravedadSeleccionada == nivel;

                return InkWell(
                  onTap: () => setState(() => _gravedadSeleccionada = nivel),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: seleccionado
                            ? const Color(0xFF0D3B66)
                            : Colors.grey.shade300,
                        width: seleccionado ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      nivel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: seleccionado
                            ? const Color(0xFF0D3B66)
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // Botón Acción Guardar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D3B66),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _cargando ? null : _guardarNovedad,
                child: _cargando
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Guardar Novedad',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}