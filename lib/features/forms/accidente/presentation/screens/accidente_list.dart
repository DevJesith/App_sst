import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/forms/accidente/presentation/providers/accidente_providers.dart';
import 'package:app_sst/features/forms/accidente/presentation/screens/accidente_detalle_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

/// Widget que muestra el listado de accidentes registrados.
///
/// Incluye:
/// * Filtrado por busqueda (Eventualidad, Proyecto, Usuario).
/// * Visualización en tarjetas con resumen.
/// * Navegación al detalle
class AccidentesList extends HookConsumerWidget {
  final String searchQuery;

  const AccidentesList({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos el estado de los accidentes y la lista de usuarios (para saber quien reportó).
    final accidenteState = ref.watch(accidenteNotifierProvider);
    final usuariosAsync = ref.watch(obtenerTodosUsuariosProvider);

    // Cargar proyectos para mostrar nombres reales
    final getProyectos = ref.read(getProyectosUseCaseProvider);
    final listaProyectos = useState<List<Map<String, dynamic>>>([]);

    useEffect(() {
      Future.microtask(() async {
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
        // 1. Verificar si esta cargando la lista de accidentes
        if (accidenteState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final accidentes = accidenteState.accidentes;

        // 2. Verificar si la lista esta vacía
        if (accidentes.isEmpty) {
          return _buildEmptyState();
        }

        // 3. Logica de filtrado (Busqueda)
        final filteredAccidentes = searchQuery.isEmpty
            ? accidentes
            : accidentes.where((accidente) {
                final query = searchQuery.toLowerCase();

                // Buscar nombre del usuario que reportó
                String nombreUsuario = '';
                try {
                  final u = usuarios.firstWhere(
                    (u) => u.id == accidente.usuarioId,
                  );
                  nombreUsuario = u.nombre.toLowerCase();
                } catch (_) {
                  // Si no encuentra usuario, nombreUsuario se queda vacio
                }
                // Filtramos si coincide con: Eventualidad, Proyecto o nombre de usuario
                return accidente.eventualidad.toLowerCase().contains(query) ||
                    nombreUsuario.contains(query);
              }).toList();

        if (filteredAccidentes.isEmpty) {
          return const Center(
            child: Text(
              'No se encontraron resultados',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // 4. Construccion de la lista
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredAccidentes.length,
          itemBuilder: (context, index) {
            final accidente = filteredAccidentes[index];

            // Obtener datos del usuario de forma segura
            String nombreUsuario = "Usuario desconocido";
            String emailUsuario = "";

            try {
              final usuario = usuarios.firstWhere(
                (u) => u.id == accidente.usuarioId,
              );
              nombreUsuario = usuario.nombre;
              emailUsuario = usuario.email;
            } catch (_) {}

            // Buscar nombre del proyecto
            String nombreProyecto = "ID: ${accidente.proyectoId}";
            if (listaProyectos.value.isNotEmpty) {
              try {
                final p = listaProyectos.value.firstWhere((p) => p['id'] == accidente.proyectoId);
                nombreProyecto = p['Nombre'] ?? p['nombre'] ?? nombreProyecto;
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
                          AccidenteDetalleScreen(accidente: accidente),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado: Icono y título
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.red.shade700,
                            radius: 20,
                            child: const Icon(
                              Icons.warning,
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
                                  accidente.eventualidad,
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
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Fecha pequeña a la derecha
                          Text(
                            DateFormat(
                              'dd/MM/yy',
                            ).format(accidente.fechaRegistro),
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

                      // Pie de tarjeta: Usuario que reportó
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
            'No hay reportes de accidentes',
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
