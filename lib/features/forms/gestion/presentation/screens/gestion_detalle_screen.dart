import 'package:app_sst/features/forms/gestion/presentation/providers/gestion_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/gestion.dart';
import 'dart:io'; // Importar para manejar archivos

/// Pantalla que muestra todos los detalles de una gestión reportada
class GestionDetalleScreen extends HookConsumerWidget {
  final Gestion gestion;

  const GestionDetalleScreen({super.key, required this.gestion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(gestion.fechaRegistro);

    // 1. Obtener el caso de uso para traer los proyectos
    final getProyectos = ref.read(getProyectosGestionUseCaseProvider);

    // 2. Crear un estado local para guardar el nombre del proyecto
    final nombreProyecto = useState<String>('Cargando...');

    // 3. Efecto para buscar el nombre del proyecto basado en el ID
    useEffect(() {
      Future.microtask(() async {
        try {
          final lista = await getProyectos();
          final proyectoEncontrado = lista.firstWhere(
            (p) => p['id'] == gestion.proyectoId,
            orElse: () => {'Nombre': 'Desconocido (ID: ${gestion.proyectoId})'},
          );
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
        title: const Text('Detalle de Gestión'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con proyecto
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestión de Inspección',
                    style: TextStyle(
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
                      // ✅ USAR EL NOMBRE DEL PROYECTO
                      nombreProyecto.value,
                      style: TextStyle(
                        color: Colors.green.shade700,
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
                      // ✅ USAR EL NOMBRE DEL PROYECTO
                      _buildInfoRow('Proyecto', nombreProyecto.value),
                      _buildInfoRow('EE (Elementos de Emergencia)', gestion.ee),
                      _buildInfoRow('Fecha de Registro', fechaFormateada),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta de EPP y Locativa
                  _buildInfoCard(
                    title: 'EPP y Locativa',
                    icon: Icons.security_outlined,
                    children: [
                      _buildInfoRow('EPP', gestion.epp),
                      _buildInfoRow('Locativa', gestion.locativa),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta de Máquinas
                  _buildInfoCard(
                    title: 'Gestión de Máquinas',
                    icon: Icons.engineering_outlined,
                    children: [
                      _buildInfoRow('Extintor Máquina', gestion.extintorMaquina),
                      _buildInfoRow('Rutinaria Máquina', gestion.rutinariaMaquina),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta de Cumplimiento
                  _buildInfoCard(
                    title: 'Estado de Cumplimiento',
                    icon: Icons.check_circle_outline,
                    children: [
                      Row(
                        children: [
                          Icon(
                            gestion.gestionCumple.toLowerCase() == 'sí' || gestion.gestionCumple.toLowerCase() == 'si'
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: gestion.gestionCumple.toLowerCase() == 'sí' || gestion.gestionCumple.toLowerCase() == 'si'
                                ? Colors.green
                                : Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              gestion.gestionCumple.toLowerCase() == 'sí' || gestion.gestionCumple.toLowerCase() == 'si'
                                  ? 'Gestión cumple con los requisitos'
                                  : 'Gestión NO cumple con los requisitos',
                              style: TextStyle(
                                fontSize: 16,
                                color: gestion.gestionCumple.toLowerCase() == 'sí' || gestion.gestionCumple.toLowerCase() == 'si'
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta de Evidencias Fotográficas
                  _buildInfoCard(
                    title: 'Evidencias Fotográficas',
                    icon: Icons.photo_library_outlined,
                    children: [_buildPhotoSection(gestion)],
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
                            gestion.sincronizado == 1 ? Icons.check_circle : Icons.pending,
                            color: gestion.sincronizado == 1 ? Colors.green : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            gestion.sincronizado == 1 ? 'Sincronizado' : 'Pendiente de sincronización',
                            style: TextStyle(
                              fontSize: 16,
                              color: gestion.sincronizado == 1 ? Colors.green : Colors.orange,
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
                Icon(icon, color: Colors.green.shade700, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
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
        style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${fotos.length} foto${fotos.length != 1 ? 's' : ''} adjunta${fotos.length != 1 ? 's' : ''}',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fotos.asMap().entries.map((entry) {
            final index = entry.key;
            final fotoPath = entry.value;
            final file = File(fotoPath);

            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    // ✅ MOSTRAR LA IMAGEN REAL
                    child: Image.file(
                      file,
                      fit: BoxFit.cover,
                      // Manejo de error si la foto no existe
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.broken_image, size: 40, color: Colors.grey.shade400);
                      },
                    ),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        'Foto ${index + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}