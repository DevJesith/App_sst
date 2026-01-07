import 'package:app_sst/features/forms/capacitacion/presentation/screens/capacitacion_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/capacitacion.dart';
import '../providers/capacitacion_providers.dart';

class CapacitacionDetalleScreen extends HookConsumerWidget {
  final Capacitacion capacitacion;

  const CapacitacionDetalleScreen({super.key, required this.capacitacion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // --- LOGICA DE ACTUALIZACION EN TIEMPO REAL ---
    final listaCapacitaciones = ref.watch(
      capacitacionesListProvider,
    ); 
    Capacitacion capacitacionMostrada = capacitacion;

    try {
      capacitacionMostrada = listaCapacitaciones.firstWhere(
        (e) => e.id == capacitacion.id,
      );
    } catch (_) {}
    // ----------------------------------------------

    final fechaFormateada = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(capacitacionMostrada.fechaRegistro);

    // --- LOGICA PARA TRAER NOMBRES REALES ---
    final getProyectos = ref.read(getProyectosCapacitacionUseCaseProvider);
    final getContratistas = ref.read(
      getContratistasCapacitacionUseCaseProvider,
    );

    final nombreProyecto = useState('Cargando...');
    final nombreContratista = useState('Cargando...');

    // Dependencia [capacitacionMostrada]
    useEffect(() {
      Future.microtask(() async {
        try {
          // 1. Buscar Proyecto
          final proyectos = await getProyectos();
          final p = proyectos.firstWhere(
            (e) => e['id'] == capacitacionMostrada.idProyecto,
            orElse: () => {},
          );
          nombreProyecto.value =
              p['Nombre'] ??
              p['nombre'] ??
              'ID: ${capacitacionMostrada.idProyecto}';

          // 2. Buscar Contratista
          final contratistas = await getContratistas(
            capacitacionMostrada.idProyecto,
          );
          final c = contratistas.firstWhere(
            (e) => e['id'] == capacitacionMostrada.idContratista,
            orElse: () => {},
          );
          nombreContratista.value =
              c['Nombre'] ??
              c['nombre'] ??
              'ID: ${capacitacionMostrada.idContratista}';
        } catch (_) {
          nombreProyecto.value = 'No encontrado';
          nombreContratista.value = 'No encontrado';
        }
      });
      return null;
    }, [capacitacionMostrada]); // <--- SE EJECUTA SI CAMBIA LA CAPACITACION

    // --- LOGICA DE ELIMINAR ---
    Future<void> confirmarEliminacion() async {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Eliminar reporte?'),
          content: const Text('Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );

      if (confirmar != true) return;

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }

      try {
        await ref
            .read(capacitacionNotifierProvider.notifier)
            .deleteCapacitacion(capacitacionMostrada.id!);

        if (context.mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Detalle Capacitación'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (capacitacionMostrada.sincronizado == 0) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  // Pasamos el actualizado
                  builder: (_) => CapacitacionFormScreen(
                    capacitacion: capacitacionMostrada,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: confirmarEliminacion,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade700,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capacitacionMostrada.descripcion, 
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
                      capacitacionMostrada.sincronizado == 1
                          ? "Sincronizado"
                          : "Pendiente de sincronización",
                      style: TextStyle(
                        color: capacitacionMostrada.sincronizado == 1
                            ? Colors.green
                            : Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- CONTENIDO ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoCard(
                    title: 'Información General',
                    icon: Icons.info_outline,
                    children: [
                      _buildInfoRow('Proyecto', nombreProyecto.value),
                      _buildInfoRow('Contratista', nombreContratista.value),
                      _buildInfoRow('Fecha', fechaFormateada),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    title: 'Detalles de la Sesión',
                    icon: Icons.class_outlined,
                    children: [
                      _buildInfoRow(
                        'Responsable',
                        capacitacionMostrada.responsable,
                      ),
                      _buildInfoRow(
                        'N° Capacitación',
                        '${capacitacionMostrada.numeroCapacita}',
                      ),
                      _buildInfoRow(
                        'Asistentes',
                        '${capacitacionMostrada.numeroPersonas}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    title: 'Estado de Sincronización',
                    icon: Icons.cloud_sync,
                    children: [
                      Row(
                        children: [
                          Icon(
                            capacitacionMostrada.sincronizado == 1
                                ? Icons.check_circle
                                : Icons.pending,
                            color: capacitacionMostrada.sincronizado == 1
                                ? Colors.green
                                : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            capacitacionMostrada.sincronizado == 1
                                ? 'Sincronizado'
                                : 'Pendiente de sincronización',
                            style: TextStyle(
                              fontSize: 16,
                              color: capacitacionMostrada.sincronizado == 1
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
                Icon(icon, color: Colors.teal.shade700, size: 24),
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
}
