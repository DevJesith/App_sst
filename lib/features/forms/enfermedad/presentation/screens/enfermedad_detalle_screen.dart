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
    final fecha = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(enfermedad.fechaRegistro);

    // --- LÓGICA PARA OBTENER NOMBRES REALES ---
    final getProyectos = ref.read(getProyectosEnfermedadUseCaseProvider);
    final getContratistas = ref.read(
      getContratistasEnfermedadesUseCaseProvider,
    );
    final getTrabajadores = ref.read(getTrabajadoresEnfermedadUseCaseProvider);

    final nombreProyecto = useState('Cargando...');
    final nombreContratista = useState('Cargando...');
    final nombreTrabajador = useState('Cargando...');

    useEffect(() {
      Future.microtask(() async {
        try {
          // 1. Proyecto
          final proyectos = await getProyectos();
          final p = proyectos.firstWhere(
            (e) => e['id'] == enfermedad.proyectoId,
            orElse: () => {},
          );
          nombreProyecto.value =
              p['Nombre'] ?? p['nombre'] ?? 'ID: ${enfermedad.proyectoId}';

          // 2. Contratista
          final contratistas = await getContratistas(enfermedad.proyectoId);
          final c = contratistas.firstWhere(
            (e) => e['id'] == enfermedad.contratistaId,
            orElse: () => {},
          );
          nombreContratista.value =
              c['Nombre'] ?? c['nombre'] ?? 'ID: ${enfermedad.contratistaId}';

          // 3. Trabajador
          final trabajadores = await getTrabajadores(
            enfermedad.proyectoId,
            enfermedad.contratistaId,
          );
          final t = trabajadores.firstWhere(
            (e) => e['id'] == enfermedad.trabajadorId,
            orElse: () => {},
          );
          nombreTrabajador.value =
              t['Nombres'] ?? t['nombres'] ?? 'ID: ${enfermedad.trabajadorId}';
        } catch (_) {
          nombreProyecto.value = 'Error';
          nombreContratista.value = 'Error';
          nombreTrabajador.value = 'Error';
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

      if (confirmar == true && context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        try {
          await ref
              .read(enfermedadNotifierProvider.notifier)
              .eliminarEnfermedad(enfermedad.id!);

          if (context.mounted) {
            Navigator.pop(context); // Loading
            Navigator.pop(context); // Pantalla
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
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Detalle Enfermedad'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (enfermedad.sincronizado == 0) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EnfermedadFormScreen(enfermedad: enfermedad),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard('Información General', Icons.info, [
              _row('Proyecto', nombreProyecto.value),
              _row('Contratista', nombreContratista.value),
              _row('Trabajador', nombreTrabajador.value),
              _row('Fecha', fecha),
            ]),
            const SizedBox(height: 16),
            _buildCard('Detalles del Caso', Icons.medical_services, [
              _row('Eventualidad', enfermedad.eventualidad),
              _row('Descripción', enfermedad.descripcion),
              _row('Incapacidad', '${enfermedad.diasIncapacidad} días'),
              _row('Avances', enfermedad.avances),
            ]),
            const SizedBox(height: 16),
            _buildCard('Estado', Icons.sync, [
              Row(
                children: [
                  Icon(
                    enfermedad.sincronizado == 1
                        ? Icons.check_circle
                        : Icons.pending,
                    color: enfermedad.sincronizado == 1
                        ? Colors.green
                        : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    enfermedad.sincronizado == 1 ? 'Sincronizado' : 'Pendiente',
                    style: TextStyle(
                      color: enfermedad.sincronizado == 1
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
