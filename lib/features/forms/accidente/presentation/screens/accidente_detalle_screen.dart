import 'package:app_sst/features/forms/accidente/presentation/providers/accidente_providers.dart';
import 'package:app_sst/features/forms/accidente/presentation/screens/accidente_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/accidente.dart';

class AccidenteDetalleScreen extends HookConsumerWidget {
  final Accidente accidente; 

  const AccidenteDetalleScreen({super.key, required this.accidente});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // --- LOGICA DE ACTUALIZACION EN TIEMPO REAL ---
    final listaAccidentes = ref.watch(
      accidentesListProvider,
    ); 

    Accidente accidenteMostrado = accidente;

    try {
      accidenteMostrado = listaAccidentes.firstWhere(
        (e) => e.id == accidente.id,
      );
    } catch (_) {
      // Si falla, mantenemos el original
    }
    // ----------------------------------------------

    // 1. Formateo de fecha
    final fechaFormateada = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(accidenteMostrado.fechaRegistro);

    // 2. Estados locales para los nombres (Hooks)
    final nombreProyecto = useState<String>('Cargando...');
    final nombreContratista = useState<String>('Cargando...');

    // 3. Efecto para cargar los nombres reales
    // IMPORTANTE: Dependencia [accidenteMostrado] para recargar si cambia el proyecto
    useEffect(() {
      Future<void> cargarNombres() async {
        try {
          final getProyectos = ref.read(getProyectosUseCaseProvider);
          final getAllContratistas = ref.read(
            getAllContratistasUseCaseProvider,
          );

          final resultados = await Future.wait([
            getProyectos(),
            getAllContratistas(),
          ]);

          final listaProyectos = resultados[0];
          final listaContratistas = resultados[1];

          // --- BUSCAR NOMBRE DEL PROYECTO ---
          try {
            final proyectoEncontrado = listaProyectos.firstWhere(
              (p) => p['id'] == accidenteMostrado.proyectoId,
            );
            nombreProyecto.value =
                proyectoEncontrado['Nombre'] ??
                proyectoEncontrado['nombre'] ??
                'Sin Nombre';
          } catch (_) {
            nombreProyecto.value =
                'Desconocido (ID: ${accidenteMostrado.proyectoId})';
          }

          // --- BUSCAR NOMBRE DEL CONTRATISTA ---
          try {
            final contratistaEncontrado = listaContratistas.firstWhere(
              (c) => c['id'] == accidenteMostrado.contratistaId,
            );
            nombreContratista.value =
                contratistaEncontrado['Nombre'] ??
                contratistaEncontrado['nombre'] ??
                'Sin Nombre';
          } catch (_) {
            nombreContratista.value =
                'Desconocido (ID: ${accidenteMostrado.contratistaId})';
          }
        } catch (e) {
          nombreProyecto.value = "Error de carga";
          nombreContratista.value = "Error de carga";
        }
      }

      cargarNombres();
      return null;
    }, [accidenteMostrado]); // <--- SE EJECUTA SI CAMBIA EL ACCIDENTE

    // 4. Logica para eliminar
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
        if (accidenteMostrado.id == null) throw Exception("El ID es nulo");

        await ref
            .read(accidenteNotifierProvider.notifier)
            .eliminarAccidente(accidenteMostrado.id!);

        if (context.mounted) {
          Navigator.of(context).pop(); // Cerrar loading
          Navigator.of(context).pop(); // Cerrar pantalla detalle
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
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Detalle del Accidente'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (accidenteMostrado.sincronizado == 0) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar reporte',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Pasamos el actualizado
                    builder: (_) =>
                        AccidenteFormScreen(accidente: accidenteMostrado),
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
            // --- HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accidenteMostrado.eventualidad,
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
                      accidenteMostrado.estado,
                      style: TextStyle(
                        color: _getEstadoColor(accidenteMostrado.estado),
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
                      _buildInfoRow('Mes', accidenteMostrado.mes),
                      _buildInfoRow('Fecha Registro', fechaFormateada),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    title: 'Descripción',
                    icon: Icons.description_outlined,
                    children: [
                      Text(
                        accidenteMostrado.descripcion,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    title: 'Incapacidad',
                    icon: Icons.medical_services_outlined,
                    children: [
                      _buildInfoRow(
                        'Días de Incapacidad',
                        '${accidenteMostrado.diasIncapacidad} día${accidenteMostrado.diasIncapacidad != 1 ? 's' : ''}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    title: 'Avances',
                    icon: Icons.timeline_outlined,
                    children: [
                      Text(
                        accidenteMostrado.avances.isEmpty
                            ? 'Sin avances registrados'
                            : accidenteMostrado.avances,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    title: 'Sincronización',
                    icon: Icons.cloud_sync,
                    children: [
                      Row(
                        children: [
                          Icon(
                            accidenteMostrado.sincronizado == 1
                                ? Icons.check_circle
                                : Icons.pending,
                            color: accidenteMostrado.sincronizado == 1
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            accidenteMostrado.sincronizado == 1
                                ? 'Sincronizado'
                                : 'Pendiente de sincronización',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: accidenteMostrado.sincronizado == 1
                                  ? Colors.green
                                  : Colors.orange,
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

  // ... (Widgets auxiliares y _getEstadoColor igual que antes)
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
                Icon(icon, color: Colors.red.shade700, size: 24),
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
            const Divider(height: 24),
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
      case 'cerrado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
