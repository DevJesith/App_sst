import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../domain/entities/gestion.dart';
import '../providers/gestion_providers.dart';
import 'gestion_form.dart';

class GestionDetalleScreen extends HookConsumerWidget {
  final Gestion gestion;

  const GestionDetalleScreen({super.key, required this.gestion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // --- LOGICA DE ACTUALIZACION EN TIEMPO REAL ---
    final listaGestiones = ref.watch(
      gestionesListProvider,
    ); 

    Gestion gestionMostrada = gestion;

    try {
      gestionMostrada = listaGestiones.firstWhere((e) => e.id == gestion.id);
    } catch (_) {}
    // ----------------------------------------------

    final fechaFormateada = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(gestionMostrada.fechaRegistro);

    // --- LOGICA PARA OBTENER NOMBRE DEL PROYECTO ---
    final getProyectos = ref.read(getProyectosGestionUseCaseProvider);
    final nombreProyecto = useState('Cargando...');

    // Dependencia [gestionMostrada]
    useEffect(() {
      Future.microtask(() async {
        try {
          final lista = await getProyectos();
          final p = lista.firstWhere(
            (e) => e['id'] == gestionMostrada.proyectoId,
            orElse: () => {},
          );
          nombreProyecto.value =
              p['Nombre'] ?? p['nombre'] ?? 'ID: ${gestionMostrada.proyectoId}';
        } catch (_) {
          nombreProyecto.value = 'Error';
        }
      });
      return null;
    }, [gestionMostrada]); // <--- SE EJECUTA SI CAMBIA LA GESTION

    // --- LOGICA DE ELIMINACION ---
    Future<void> confirmarEliminacion() async {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Eliminar gestión?'),
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
              .read(gestionNotifierProvider.notifier)
              .eliminarGestion(gestionMostrada.id!);

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
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Detalle de Gestión'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (gestionMostrada.sincronizado == 0) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar gestión',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  // Pasamos el actualizado
                  builder: (_) => GestionFormScreen(gestion: gestionMostrada),
                ),
              ),
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
                color: Colors.purple.shade700,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombreProyecto.value,
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
                      gestionMostrada.ee,
                      style: TextStyle(
                        color: Colors.purple.shade700,
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
                      _buildInfoRow('EE', gestionMostrada.ee),
                      _buildInfoRow('Fecha de Registro', fechaFormateada),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    title: 'Seguridad',
                    icon: Icons.security_outlined,
                    children: [
                      _buildInfoRow('EPP', gestionMostrada.epp),
                      _buildInfoRow('Locativa', gestionMostrada.locativa),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    title: 'Maquinaria',
                    icon: Icons.engineering_outlined,
                    children: [
                      _buildInfoRow(
                        'Extintor',
                        gestionMostrada.extintorMaquina,
                      ),
                      _buildInfoRow(
                        'Rutinaria',
                        gestionMostrada.rutinariaMaquina,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    title: 'Evidencias Fotográficas',
                    icon: Icons.photo_library_outlined,
                    children: [_buildPhotoSection(gestionMostrada)],
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    title: 'Estado de Sincronización',
                    icon: Icons.cloud_sync,
                    children: [
                      Row(
                        children: [
                          Icon(
                            gestionMostrada.sincronizado == 1
                                ? Icons.check_circle
                                : Icons.pending,
                            color: gestionMostrada.sincronizado == 1
                                ? Colors.green
                                : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            gestionMostrada.sincronizado == 1
                                ? 'Sincronizado'
                                : 'Pendiente de sincronización',
                            style: TextStyle(
                              fontSize: 16,
                              color: gestionMostrada.sincronizado == 1
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
                Icon(icon, color: Colors.purple.shade700, size: 24),
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

  Widget _buildPhotoSection(Gestion gestion) {
    final fotos = [
      if (gestion.foto1.isNotEmpty) gestion.foto1,
      if (gestion.foto2.isNotEmpty) gestion.foto2,
      if (gestion.foto3.isNotEmpty) gestion.foto3,
    ];

    if (fotos.isEmpty) {
      return const Text(
        'No hay fotos adjuntas',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
          height: 1.5,
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: fotos.map((path) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(path),
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 100,
              height: 100,
              color: Colors.grey.shade200,
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 40,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
