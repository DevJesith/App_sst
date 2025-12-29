import 'package:app_sst/features/forms/accidente/presentation/providers/accidente_providers.dart';
import 'package:app_sst/features/forms/accidente/presentation/screens/accidente_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/accidente.dart';

/// Pantalla que muestra el detalle completo de un Accidente
///
/// Incluye la logica de negocio para permitir la edicion:
/// Solo s epuede editar si el registro aun no ha sido sincronizado con la nube.
class AccidenteDetalleScreen extends ConsumerWidget {
  final Accidente accidente;

  const AccidenteDetalleScreen({super.key, required this.accidente});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Formateo de fecha para mostrarla amigable
    final fechaFormateada = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(accidente.fechaRegistro);

    // Funcion para confirmar y eliminar
    Future<void> confirmarEliminacion() async {
      // 1. Mostrar el dialogo de confirmacion
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Eliminar reporte?'),
          content: const Text('Esta accion no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );

      // Si el usuario dijo que No o cerro el dialogo, no hacemos nada
      if (confirmar != true) return;

      // 2. Mostrar indicadpr de carga
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      try {
        debugPrint(
          "🗑️ Iniciando eliminación del accidente ID: ${accidente.id}",
        );

        if (accidente.id == null) {
          throw Exception("El ID del accidente es nulo");
        }

        // 3. Ejecutar eliminacion en la BD
        await ref
            .read(accidenteNotifierProvider.notifier)
            .eliminarAccidente(accidente.id!);

        debugPrint("✅ Eliminación completada en BD");

        if (context.mounted) {
          // 4. Cerrar el indicador de carga
          Navigator.of(context).pop();

          // 5. Cerrar la pantalla de detalle
          Navigator.of(context).pop();

          // 6. Mostrar mensaje de texto
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reporte eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint("❌ Error al eliminar: $e");

        // Manejo de errores
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Detalle del Accidente'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Boton de edicion
          // Solo mostramos el lapiz si el registro es local (sincronizado == 0)
          if (accidente.sincronizado == 0) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar reporte',
              onPressed: () {
                // Navegar el formulario en modo edicion
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AccidenteFormScreen(accidente: accidente),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Eliminar',
              onPressed: confirmarEliminacion,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER CON ESTADO ---
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

            // --- CONTENIDO DETALLADO ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Tarjeta 1: Informacion General
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

                  // Tarjeta 2: Descripcion
                  _buildInfoCard(
                    title: 'Descripción del Accidente',
                    icon: Icons.description_outlined,
                    children: [
                      Text(
                        accidente.descripcion,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta 3: Incapacidad
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

                  // Tarjeta 4: Avances
                  _buildInfoCard(
                    title: 'Avances',
                    icon: Icons.timeline_outlined,
                    children: [
                      Text(
                        accidente.avances,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta 5: Estado de sincronizacion
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

  // --- WIDGETS AUXILIARES ---

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
