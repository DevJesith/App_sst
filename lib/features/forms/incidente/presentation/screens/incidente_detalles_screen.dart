import 'package:app_sst/features/forms/incidente/presentation/screens/incidente_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

// Imports de Dominio, Providers y Pantallas
import '../../domain/entities/incidente.dart';
import '../providers/incidente_providers.dart';

/// Pantalla que muestra todos los detalles de un incidente reportado.
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
          final lista = await getProyectos();
          final proyectoEncontrado = lista.firstWhere(
            (p) => p['id'] == incidente.proyectoId,
            orElse: () => {'Nombre': 'Desconocido (ID: ${incidente.proyectoId})'},
          );
          nombreProyecto.value = proyectoEncontrado['Nombre'] ?? proyectoEncontrado['nombre'] ?? 'Sin nombre';
        } catch (e) {
          nombreProyecto.value = 'Error al cargar';
        }
      });
      return null;
    }, []);

    // --- LÓGICA DE ELIMINACIÓN ---
    Future<void> confirmarEliminacion() async {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Eliminar reporte?'),
          content: const Text('Esta acción no se puede deshacer.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Eliminar')),
          ],
        ),
      );

      if (confirmar == true && context.mounted) {
        showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
        
        try {
          await ref.read(incidenteNotifierProvider.notifier).eliminarIncidente(incidente.id!);
          
          if (context.mounted) {
            Navigator.pop(context); // Loading
            Navigator.pop(context); // Pantalla
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eliminado correctamente'), backgroundColor: Colors.green));
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Detalle del Incidente'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (incidente.sincronizado == 0) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => IncidenteFormScreen(incidente: incidente))),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: confirmarEliminacion,
            ),
          ]
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con estado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
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
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      incidente.estado,
                      style: TextStyle(color: _getEstadoColor(incidente.estado), fontSize: 14, fontWeight: FontWeight.bold),
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
                  _buildInfoCard(
                    title: 'Información General',
                    icon: Icons.info_outline,
                    children: [
                      _buildInfoRow('Proyecto', nombreProyecto.value),
                      _buildInfoRow('Mes', incidente.mes),
                      _buildInfoRow('Fecha de Registro', fechaFormateada),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Descripción del Incidente',
                    icon: Icons.description_outlined,
                    children: [Text(incidente.descripcion, style: const TextStyle(fontSize: 16, height: 1.5))],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Incapacidad',
                    icon: Icons.medical_services_outlined,
                    children: [_buildInfoRow('Días de Incapacidad', '${incidente.diasIncapacidad} día${incidente.diasIncapacidad != 1 ? 's' : ''}')],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Avances',
                    icon: Icons.timeline_outlined,
                    children: [Text(incidente.avances, style: const TextStyle(fontSize: 16, height: 1.5))],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Estado de Sincronización',
                    icon: Icons.sync,
                    children: [
                      Row(
                        children: [
                          Icon(incidente.sincronizado == 1 ? Icons.check_circle : Icons.pending, color: incidente.sincronizado == 1 ? Colors.green : Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Text(incidente.sincronizado == 1 ? 'Sincronizado' : 'Pendiente de sincronización', style: TextStyle(fontSize: 16, color: incidente.sincronizado == 1 ? Colors.green : Colors.orange, fontWeight: FontWeight.w500)),
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

  Widget _buildInfoCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: Colors.orange.shade700, size: 24), const SizedBox(width: 12), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
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
          Expanded(flex: 2, child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500))),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente': return Colors.orange;
      case 'en proceso': return Colors.blue;
      case 'completado': return Colors.green;
      default: return Colors.grey;
    }
  }
}