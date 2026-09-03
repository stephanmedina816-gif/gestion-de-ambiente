import 'package:flutter/material.dart';
import '../../models/equipo_model.dart';
import '../../services/equipo_service.dart';

class ReporteFormScreen extends StatefulWidget {
  final EquipoModel equipo;

  const ReporteFormScreen({super.key, required this.equipo});

  @override
  State<ReporteFormScreen> createState() => _ReporteFormScreenState();
}

class _ReporteFormScreenState extends State<ReporteFormScreen> {
  final _equipoService = EquipoService();

  bool _esOperativo = true;
  final TextEditingController _descripcionController = TextEditingController();
  String _gravedadSeleccionada = 'MEDIA';
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _esOperativo = widget.equipo.esOperativo;
    _descripcionController.text = widget.equipo.observacion;
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _cargando = true);

    try {
      await _equipoService.registrarReporteYActualizarEquipo(
        equipoId: widget.equipo.id.toString(),
        esOperativo: _esOperativo,
        descripcion: _descripcionController.text.trim(),
        gravedad: _gravedadSeleccionada,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar reporte: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Material provee el lienzo para ChoiceChip y SingleChildScrollView evita el desbordamiento
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reporte: ${widget.equipo.codigo}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Botones Operativo / Con Falla
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _esOperativo ? Colors.green.shade100 : Colors.transparent,
                        side: BorderSide(color: _esOperativo ? Colors.green : Colors.grey),
                      ),
                      onPressed: () => setState(() => _esOperativo = true),
                      child: const Text('OPERATIVO', style: TextStyle(color: Colors.green)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: !_esOperativo ? Colors.red.shade100 : Colors.transparent,
                        side: BorderSide(color: !_esOperativo ? Colors.red : Colors.grey),
                      ),
                      onPressed: () => setState(() => _esOperativo = false),
                      child: const Text('CON FALLA', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Selector de Gravedad (Solo visible si está CON FALLA)
              if (!_esOperativo) ...[
                const Text('Nivel de Gravedad:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['BAJA', 'MEDIA', 'ALTA'].map((nivel) {
                    final isSelected = _gravedadSeleccionada == nivel;
                    return ChoiceChip(
                      label: Text(nivel),
                      selected: isSelected,
                      selectedColor: nivel == 'ALTA'
                          ? Colors.red.shade200
                          : (nivel == 'MEDIA' ? Colors.orange.shade200 : Colors.yellow.shade200),
                      onSelected: (selected) {
                        if (selected) setState(() => _gravedadSeleccionada = nivel);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              const Text('Detalle de Novedad:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Describe la novedad...',
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00334E),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: _cargando ? null : _guardar,
                  child: _cargando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'GUARDAR CAMBIOS',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}