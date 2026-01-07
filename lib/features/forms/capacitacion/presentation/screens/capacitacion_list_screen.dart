import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/forms/capacitacion/presentation/providers/capacitacion_providers.dart';
import 'package:app_sst/features/forms/capacitacion/presentation/screens/capacitacion_detalle_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class CapacitacionListScreen extends HookConsumerWidget {
  final String searchQuery;

  const CapacitacionListScreen({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capacitacionState = ref.watch(capacitacionNotifierProvider);
    final usuariosAsync = ref.watch(obtenerTodosUsuariosProvider);

    // Cargar proyectos para mostrar nombres reales
    final getProyectos = ref.read(getProyectosCapacitacionUseCaseProvider);
    final listaProyectos = useState<List<Map<String, dynamic>>>([]);

    useEffect(() {
      Future.microtask(() async {
        ref.read(capacitacionNotifierProvider.notifier).loadCapacitaciones();
        try {
          final proyectos = await getProyectos();
          listaProyectos.value = proyectos;
        } catch (_) {}
      });
      return null;
    }, []);

    return usuariosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
      ),
      data: (usuarios) {
        if (capacitacionState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final capacitaciones = capacitacionState.capacitaciones;

        if (capacitaciones.isEmpty) {
          return _buildEmptyState();
        }

        // Filtrado
        final filteredList = searchQuery.isEmpty
            ? capacitaciones
            : capacitaciones.where((cap) {
                final query = searchQuery.toLowerCase();

                // Buscar nombre del usuario
                String nombreUsuario = '';
                try {
                  final u = usuarios.firstWhere((u) => u.id == cap.usuarioId);
                  nombreUsuario = u.nombre.toLowerCase();
                } catch (_) {}

                return cap.descripcion.toLowerCase().contains(query) ||
                    cap.responsable.toLowerCase().contains(query) ||
                    nombreUsuario.contains(query);
              }).toList();

        if (filteredList.isEmpty) {
          return const Center(
            child: Text(
              'No se encontraron resultados',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final cap = filteredList[index];

            // Buscar usuario
            String nombreUsuario = "Usuario desconocido";
            String emailUsuario = "";
            try {
              final usuario = usuarios.firstWhere((u) => u.id == cap.usuarioId);
              nombreUsuario = usuario.nombre;
              emailUsuario = usuario.email;
            } catch (_) {}

            // Buscar nombre del proyecto
            String nombreProyecto = "ID: ${cap.idProyecto}";
            if (listaProyectos.value.isNotEmpty) {
              try {
                final p = listaProyectos.value.firstWhere(
                  (p) => p['id'] == cap.idProyecto,
                  orElse: () => {},
                );
                nombreProyecto =
                    p['Nombre'] ?? p['nombre'] ?? 'ID: ${cap.idProyecto}';
              } catch (_) {}
            }

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CapacitacionDetalleScreen(capacitacion: cap),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.purple.shade700,
                            radius: 20,
                            child: const Icon(
                              Icons.menu_book,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cap.descripcion,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  nombreProyecto,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.purple.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yy').format(cap.fechaRegistro),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 8),

                      // Pie de tarjeta (Usuario)
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nombre: $nombreUsuario',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  emailUsuario,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay capacitaciones registradas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
