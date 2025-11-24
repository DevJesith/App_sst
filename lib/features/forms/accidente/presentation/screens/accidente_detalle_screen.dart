// features/forms/accidente/presentation/screens/accidente_detalle_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/accidente.dart';

/// Pantalla que muestra todos los detalles de un accidente reportado
class AccidenteDetalleScreen extends StatelessWidget {
  final Accidente accidente;

  const AccidenteDetalleScreen({
    super.key,
    required this.accidente,
  });

  @override
  Widget build(BuildContext context) {
    final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm')
        .format(accidente.fechaRegistro);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Detalle del Accidente'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con estado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accidente.eventualidad,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      accidente.estado,
                      style: TextStyle(
                        color: _getEstadoColor(accidente.estado),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Tarjeta de información general
                  _buildInfoCard(
                    title: 'Información General',
                    icon: Icons.info_outline,
                    children: [
                      _buildInfoRow('Proyecto', accidente.proyecto),
                      _buildInfoRow('Contratista', accidente.contratista),
                      _buildInfoRow('Mes', accidente.mes),
                      _buildInfoRow('Fecha de Registro', fechaFormateada),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta de descripción
                  _buildInfoCard(
                    title: 'Descripción del Accidente',
                    icon: Icons.description_outlined,
                    children: [
                      Text(
                        accidente.descripcion,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta de incapacidad
                  _buildInfoCard(
                    title: 'Incapacidad',
                    icon: Icons.medical_services_outlined,
                    children: [
                      _buildInfoRow(
                        'Días de Incapacidad',
                        '${accidente.diasIncapacidad} día${accidente.diasIncapacidad != 1 ? 's' : ''}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta de avances
                  _buildInfoCard(
                    title: 'Avances',
                    icon: Icons.timeline_outlined,
                    children: [
                      Text(
                        accidente.avances,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta de sincronización
                  _buildInfoCard(
                    title: 'Estado de Sincronización',
                    icon: Icons.sync,
                    children: [
                      Row(
                        children: [
                          Icon(
                            accidente.sincronizado == 1
                                ? Icons.check_circle
                                : Icons.pending,
                            color: accidente.sincronizado == 1
                                ? Colors.green
                                : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            accidente.sincronizado == 1
                                ? 'Sincronizado'
                                : 'Pendiente de sincronización',
                            style: TextStyle(
                              fontSize: 16,
                              color: accidente.sincronizado == 1
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
        return Colors.blue;
      case 'completado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}