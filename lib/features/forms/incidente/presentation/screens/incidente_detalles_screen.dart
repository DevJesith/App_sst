import 'package:app_sst/features/forms/incidente/presentation/providers/incidente_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/incidente.dart';

/// Pantalla que muestra todos los detalles de un incidente reportado
class IncidenteDetallesScreen extends HookConsumerWidget {
  final Incidente incidente;

  const IncidenteDetallesScreen({super.key, required this.incidente});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(incidente.fechaRegistro);

    // 1. Obtener el caso de uso para traer los proyectos
    final getProyectos = ref.read(getProyectosIncidenteUseCaseProvider);

    // 2. Crear un estado local para guardar el nombre del proyecto
    final nombreProyecto = useState<String>('Cargando...');

    // 3. Efecto para buscar el nombre del proyecto basado en el ID
    useEffect(() {
      Future.microtask(() async {
        try {
          // Traemos la lista de proyectos de la BD
          final lista = await getProyectos();
          
          // Buscamos el que coincida con el ID del incidente
          final proyectoEncontrado = lista.firstWhere(
            (p) => p['id'] == incidente.proyectoId,
            orElse: () => {'Nombre': 'Desconocido (ID: ${incidente.proyectoId})'},
          );

          // Actualizamos el estado con el nombre
          nombreProyecto.value = proyectoEncontrado['Nombre'] ?? proyectoEncontrado['nombre'] ?? 'Sin nombre';
        } catch (e) {
          nombreProyecto.value = 'Error al cargar';
        }
      });
      return null;
    }, []);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Detalle del Incidente'),
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
                    incidente.eventualidad,
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
                      incidente.estado,
                      style: TextStyle(
                        color: _getEstadoColor(incidente.estado),
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
                      // ✅ AQUI USAMOS EL NOMBRE TRADUCIDO
                      _buildInfoRow('Proyecto', nombreProyecto.value),
                      _buildInfoRow('Mes', incidente.mes),
                      _buildInfoRow('Fecha de Registro', fechaFormateada),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta de descripción
                  _buildInfoCard(
                    title: 'Descripción del Incidente',
                    icon: Icons.description_outlined,
                    children: [
                      Text(
                        incidente.descripcion,
                        style: const TextStyle(fontSize: 16, height: 1.5),
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
                        '${incidente.diasIncapacidad} día${incidente.diasIncapacidad != 1 ? 's' : ''}',
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
                        incidente.avances,
                        style: const TextStyle(fontSize: 16, height: 1.5),
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
                            incidente.sincronizado == 1
                                ? Icons.check_circle
                                : Icons.pending,
                            color: incidente.sincronizado == 1
                                ? Colors.green
                                : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            incidente.sincronizado == 1
                                ? 'Sincronizado'
                                : 'Pendiente de sincronización',
                            style: TextStyle(
                              fontSize: 16,
                              color: incidente.sincronizado == 1
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700, size: 24),
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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