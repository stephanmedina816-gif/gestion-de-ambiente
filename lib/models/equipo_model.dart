class EquipoModel {
  final int id;
  final String codigo;
  final String nombre;
  final String estado;
  final String observacion;

  EquipoModel({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.estado,
    this.observacion = '',
  });

  bool get esOperativo => estado.toUpperCase() == 'OPERATIVO';

  factory EquipoModel.fromMap(Map<String, dynamic> map) {
    return EquipoModel(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id'].toString()) ?? 0,
      codigo: map['codigo']?.toString() ?? map['nombre']?.toString() ?? 'PC-317-00',
      nombre: map['nombre']?.toString() ?? map['codigo']?.toString() ?? 'PC-317-00',
      estado: map['estado'] is bool
          ? ((map['estado'] as bool) ? 'OPERATIVO' : 'CON FALLA')
          : (map['estado']?.toString() ?? 'OPERATIVO'),
      observacion: map['observacion']?.toString() ?? map['descripcion']?.toString() ?? '',
    );
  }

  // Alias desde JSON para compatibilidad con equipo_service.dart
  factory EquipoModel.fromJson(Map<String, dynamic> json) => EquipoModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'estado': estado,
      'observacion': observacion,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}