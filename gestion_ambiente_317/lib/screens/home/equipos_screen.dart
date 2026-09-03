import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/equipo_model.dart';
import '../../widgets/equipo_card.dart';

class EquiposScreen extends StatelessWidget {
  const EquiposScreen({super.key});

  void _mostrarModalReporte(BuildContext context, EquipoModel equipo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _ModalReporteEquipo(equipo: equipo);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Ambiente 317 - SENA',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0D3B66),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('equipos')
            .stream(primaryKey: ['id']).order('id', ascending: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error al cargar equipos: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text(
                'No hay equipos registrados',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final equipos = data.map((map) => EquipoModel.fromMap(map)).toList();
          final operativos = equipos.where((e) => e.esOperativo).length;
          final conFalla = equipos.length - operativos;

          return Column(
            children: [
              // Tarjetas de Resumen
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _ResumenCard(
                        count: operativos,
                        label: 'Operativos',
                        backgroundColor: Colors.green.shade100,
                        borderColor: Colors.green.shade300,
                        textColor: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ResumenCard(
                        count: conFalla,
                        label: 'Con Falla',
                        backgroundColor: Colors.red.shade100,
                        borderColor: Colors.red.shade300,
                        textColor: Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ),

              // Grid de PCs
              Expanded(
                child: GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: equipos.length,
                  itemBuilder: (context, index) {
                    final equipo = equipos[index];

                    return EquipoCard(
                      equipo: equipo,
                      onTap: () => _mostrarModalReporte(context, equipo),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ModalReporteEquipo extends StatefulWidget {
  final EquipoModel equipo;

  const _ModalReporteEquipo({required this.equipo});

  @override
  State<_ModalReporteEquipo> createState() => _ModalReporteEquipoState();
}

class _ModalReporteEquipoState extends State<_ModalReporteEquipo> {
  late bool _esOperativo;
  String _gravedad = 'MEDIA';
  late TextEditingController _controller;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _esOperativo = widget.equipo.esOperativo;
    _controller = TextEditingController(text: widget.equipo.observacion);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    setState(() => _guardando = true);
    final supabase = Supabase.instance.client;
    final nuevoEstado = _esOperativo ? 'OPERATIVO' : 'CON FALLA';
    final descripcion = _controller.text.trim();

    try {
      // 1. Actualizar el estado en la tabla 'equipos'
      await supabase.from('equipos').update({
        'estado': nuevoEstado,
      }).eq('id', widget.equipo.id);

      // 2. Insertar en 'reportes_fallas' con la columna 'estado_reporte'
      await supabase.from('reportes_fallas').insert({
        'equipo_id': widget.equipo.id,
        'descripcion': descripcion.isEmpty
            ? (_esOperativo ? 'Sin novedad' : 'Reporte de falla registrado')
            : descripcion,
        'gravedad': !_esOperativo ? _gravedad : 'NINGUNA',
        'estado_reporte': _esOperativo ? 'SOLUCIONADO' : 'PENDIENTE',
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Reporte e historial guardados correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  Widget _buildGravedadChip(String nivel, Color colorSeleccionado) {
    final estaSeleccionado = _gravedad == nivel;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gravedad = nivel),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: estaSeleccionado ? colorSeleccionado : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: estaSeleccionado
                  ? Colors.orange.shade400
                  : Colors.purple.shade200,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (estaSeleccionado) ...[
                const Icon(Icons.check, size: 16, color: Colors.black87),
                const SizedBox(width: 4),
              ],
              Text(
                nivel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color:
                      estaSeleccionado ? Colors.black87 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Reporte: ${widget.equipo.codigo}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Selección OPERATIVO / CON FALLA
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _esOperativo = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          _esOperativo ? Colors.green.shade100 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _esOperativo
                            ? Colors.green.shade400
                            : Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'OPERATIVO',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _esOperativo
                            ? Colors.green.shade700
                            : Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _esOperativo = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_esOperativo ? Colors.red.shade100 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: !_esOperativo
                            ? Colors.red.shade400
                            : Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'CON FALLA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: !_esOperativo
                            ? Colors.red.shade700
                            : Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Nivel de Gravedad
          if (!_esOperativo) ...[
            const Text(
              'Nivel de Gravedad:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildGravedadChip('BAJA', const Color(0xFFFFE0B2)),
                const SizedBox(width: 8),
                _buildGravedadChip('MEDIA', const Color(0xFFFFCC80)),
                const SizedBox(width: 8),
                _buildGravedadChip('ALTA', const Color(0xFFFFB74D)),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Detalle de Novedad
          const Text(
            'Detalle de Novedad:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe la novedad...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Botón GUARDAR CAMBIOS
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D3B66),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: _guardando ? null : _guardarCambios,
              child: _guardando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'GUARDAR CAMBIOS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final int count;
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const _ResumenCard({
    required this.count,
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
