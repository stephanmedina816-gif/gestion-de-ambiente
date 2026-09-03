import 'package:flutter/material.dart';
import '../models/equipo_model.dart';

class EquipoCard extends StatelessWidget {
  final EquipoModel equipo;
  final VoidCallback? onTap;

  const EquipoCard({
    super.key,
    required this.equipo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final esOp = equipo.esOperativo;

    return Card(
      elevation: 2,
      color: esOp ? Colors.green.shade50 : Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: esOp ? Colors.green.shade400 : Colors.red.shade400,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.computer,
                size: 32,
                color: esOp ? Colors.green.shade700 : Colors.red.shade700,
              ),
              const SizedBox(height: 6),
              Text(
                equipo.codigo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: esOp ? Colors.green.shade900 : Colors.red.shade900,
                ),
              ),
              if (equipo.observacion.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  equipo.observacion,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}