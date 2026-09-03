import 'package:flutter/material.dart';

class AmbientesScreen extends StatelessWidget {
  const AmbientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> ambientes = [
      {
        'codigo': '317',
        'nombre': 'Ambiente 317 - ADSO',
        'especialidad': 'Análisis y Desarrollo de Software',
        'equipos': 30,
        'activo': true,
      },
      {
        'codigo': '318',
        'nombre': 'Ambiente 318 - Redes',
        'especialidad': 'Infraestructura y Telecomunicaciones',
        'equipos': 25,
        'activo': false,
      },
      {
        'codigo': '302',
        'nombre': 'Ambiente 302 - Multimedia',
        'especialidad': 'Diseño e Interacción Digital',
        'equipos': 28,
        'activo': false,
      },
      {
        'codigo': '201',
        'nombre': 'Ambiente 201 - Hardware',
        'especialidad': 'Mantenimiento de Equipos',
        'equipos': 20,
        'activo': false,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Selección de Ambientes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0D3B66),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: ambientes.length,
        itemBuilder: (context, index) {
          final item = ambientes[index];
          final bool esActivo = item['activo'] as bool;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: esActivo ? 3 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: esActivo ? const Color(0xFF0D3B66) : Colors.transparent,
                width: esActivo ? 2 : 0,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: esActivo
                    ? const Color(0xFF0D3B66)
                    : Colors.blue.shade50,
                child: Icon(
                  Icons.meeting_room_rounded,
                  color: esActivo ? Colors.white : const Color(0xFF0D3B66),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['nombre'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (esActivo)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'ACTIVO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['especialidad'] as String,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.computer,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item['equipos']} Equipos registrados',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}