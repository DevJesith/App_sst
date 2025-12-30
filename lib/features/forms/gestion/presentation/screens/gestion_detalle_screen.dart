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
    final fechaFormateada = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(gestion.fechaRegistro);

    // --- LÓGICA PARA OBTENER NOMBRE DEL PROYECTO ---
    final getProyectos = ref.read(getProyectosGestionUseCaseProvider);
    final nombreProyecto = useState('Cargando...');

    useEffect(() {
      Future.microtask(() async {
        try {
          final lista = await getProyectos();
          final p = lista.firstWhere(
            (e) => e['id'] == gestion.proyectoId,
            orElse: () => {},
          );
          nombreProyecto.value =
              p['Nombre'] ?? p['nombre'] ?? 'ID: ${gestion.proyectoId}';
        } catch (_) {
          nombreProyecto.value = 'Error';
        }
      });
      return null;
    }, []);

    // --- LÓGICA DE ELIMINACIÓN ---
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
              .eliminarGestion(gestion.id!);

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
        title: const Text('Detalle de Gestión'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (gestion.sincronizado == 0) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GestionFormScreen(gestion: gestion),
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
              _row('EE', gestion.ee),
              _row('Fecha', fechaFormateada),
            ]),
            const SizedBox(height: 16),
            _buildCard('Seguridad', Icons.security, [
              _row('EPP', gestion.epp),
              _row('Locativa', gestion.locativa),
            ]),
            const SizedBox(height: 16),
            _buildCard('Maquinaria', Icons.engineering, [
              _row('Extintor', gestion.extintorMaquina),
              _row('Rutinaria', gestion.rutinariaMaquina),
            ]),
            const SizedBox(height: 16),
            _buildCard('Evidencias', Icons.photo_library, [
              _buildPhotoSection(gestion),
            ]),
            const SizedBox(height: 16),
            _buildCard('Estado', Icons.sync, [
              Row(
                children: [
                  Icon(
                    gestion.sincronizado == 1
                        ? Icons.check_circle
                        : Icons.pending,
                    color: gestion.sincronizado == 1
                        ? Colors.green
                        : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    gestion.sincronizado == 1 ? 'Sincronizado' : 'Pendiente',
                    style: TextStyle(
                      color: gestion.sincronizado == 1
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
                Icon(icon, color: Colors.green.shade700),
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

  Widget _buildPhotoSection(Gestion gestion) {
    final fotos = [
      if (gestion.foto1.isNotEmpty) gestion.foto1,
      if (gestion.foto2.isNotEmpty) gestion.foto2,
      if (gestion.foto3.isNotEmpty) gestion.foto3,
    ];

    if (fotos.isEmpty)
      return const Text(
        'No hay fotos adjuntas',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: fotos.map((path) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(path),
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          ),
        );
      }).toList(),
    );
  }
}
