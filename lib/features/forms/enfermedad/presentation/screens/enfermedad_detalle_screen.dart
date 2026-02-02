import 'package:app_sst/features/forms/enfermedad/presentation/screens/enfermedad_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/enfermedad.dart';
import '../providers/enfermedad_providers.dart';

class EnfermedadDetalleScreen extends HookConsumerWidget {
  final Enfermedad enfermedad;

  const EnfermedadDetalleScreen({super.key, required this.enfermedad});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // --- LOGICA DE ACTUALIZACION EN TIEMPO REAL ---
    final listaEnfermedades = ref.watch(
      enfermedadListProvider,
    ); 

    Enfermedad enfermedadMostrada = enfermedad;

    try {
      enfermedadMostrada = listaEnfermedades.firstWhere(
        (e) => e.id == enfermedad.id,
      );
    } catch (_) {}
    // ----------------------------------------------

    final fechaFormateada = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(enfermedadMostrada.fechaRegistro);

    // --- LÓGICA PARA OBTENER NOMBRES REALES ---
    final getProyectos = ref.read(getProyectosEnfermedadUseCaseProvider);
    final getContratistas = ref.read(
      getContratistasEnfermedadesUseCaseProvider,
    );
    final getTrabajadores = ref.read(getTrabajadoresEnfermedadUseCaseProvider);

    final nombreProyecto = useState('Cargando...');
    final nombreContratista = useState('Cargando...');
    final nombreTrabajador = useState('Cargando...');

    // Dependencia [enfermedadMostrada]
    useEffect(() {
      Future.microtask(() async {
        try {
          // 1. Proyecto
          final proyectos = await getProyectos();
          final p = proyectos.firstWhere(
            (e) => e['id'] == enfermedadMostrada.proyectoId,
            orElse: () => {},
          );
          nombreProyecto.value = p.isNotEmpty
              ? (p['Nombre'] ??
                    p['nombre'] ??
                    'ID: ${enfermedadMostrada.proyectoId}')
              : 'ID: ${enfermedadMostrada.proyectoId}';

          // 2. Contratista
          final contratistas = await getContratistas(
            enfermedadMostrada.proyectoId,
          );
          final c = contratistas.firstWhere(
            (e) => e['id'] == enfermedadMostrada.contratistaId,
            orElse: () => {},
          );
          nombreContratista.value = c.isNotEmpty
              ? (c['Nombre'] ??
                    c['nombre'] ??
                    'ID: ${enfermedadMostrada.contratistaId}')
              : 'ID: ${enfermedadMostrada.contratistaId}';

          // 3. Trabajador
          final trabajadores = await getTrabajadores(
            enfermedadMostrada.proyectoId,
            enfermedadMostrada.contratistaId,
          );
          final t = trabajadores.firstWhere(
            (e) => e['id'] == enfermedadMostrada.trabajadorId,
            orElse: () => {},
          );
          nombreTrabajador.value = t.isNotEmpty
              ? (t['Nombres'] ??
                    t['nombres'] ??
                    t['Nombre'] ??
                    t['nombre'] ??
                    'ID: ${enfermedadMostrada.trabajadorId}')
              : 'ID: ${enfermedadMostrada.trabajadorId}';
        } catch (e) {
          nombreProyecto.value = 'Error';
          nombreContratista.value = 'Error';
          nombreTrabajador.value = 'Error';
        }
      });
      return null;
    }, [enfermedadMostrada]); // <--- SE EJECUTA SI CAMBIA LA ENFERMEDAD

    // --- LÓGICA DE ELIMINACIÓN ---
    Future<void> confirmarEliminacion() async {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Eliminar reporte?'),
          content: const Text('Esta acción no se puede deshacer.'),
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

      if (confirmar != true) return;

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      try {
        await ref
            .read(enfermedadNotifierProvider.notifier)
            .eliminarEnfermedad(enfermedadMostrada.id!);

        if (context.mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reporte eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
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
        title: const Text('Detalle de Enfermedad'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (enfermedadMostrada.sincronizado == 0) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar reporte',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Pasamos el actualizado
                    builder: (_) =>
                        EnfermedadFormScreen(enfermedad: enfermedadMostrada),
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // --- HEADER ---
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
                        enfermedadMostrada.eventualidad,
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
                          enfermedadMostrada.estado,
                          style: TextStyle(
                            color: Colors.blue.shade700,
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
                          _buildInfoRow('Trabajador', nombreTrabajador.value),
                          _buildInfoRow('Fecha de Registro', fechaFormateada),
                        ],
                      ),
                      const SizedBox(height: 16),
          
                      _buildInfoCard(
                        title: 'Detalles del Caso',
                        icon: Icons.medical_services_outlined,
                        children: [
                          _buildInfoRow(
                            'Eventualidad',
                            enfermedadMostrada.eventualidad,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            enfermedadMostrada.descripcion,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
          
                      _buildInfoCard(
                        title: 'Incapacidad',
                        icon: Icons.calendar_today_outlined,
                        children: [
                          _buildInfoRow(
                            'Días de Incapacidad',
                            '${enfermedadMostrada.diasIncapacidad} día${enfermedadMostrada.diasIncapacidad != 1 ? 's' : ''}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
          
                      _buildInfoCard(
                        title: 'Avances',
                        icon: Icons.timeline_outlined,
                        children: [
                          Text(
                            enfermedadMostrada.avances,
                            style: const TextStyle(fontSize: 16, height: 1.5),
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
                                enfermedadMostrada.sincronizado == 1
                                    ? Icons.check_circle
                                    : Icons.pending,
                                color: enfermedadMostrada.sincronizado == 1
                                    ? Colors.green
                                    : Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                enfermedadMostrada.sincronizado == 1
                                    ? 'Sincronizado'
                                    : 'Pendiente de sincronización',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: enfermedadMostrada.sincronizado == 1
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
}
