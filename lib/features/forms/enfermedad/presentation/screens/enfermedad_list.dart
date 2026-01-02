import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

// Imports de Providers y Pantallas
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/enfermedad_providers.dart';
import 'enfermedad_detalle_screen.dart';

/// Widget que muestra el listado de enfermedades laborales registradas.
class EnfermedadesList extends HookConsumerWidget {
  final String searchQuery;

  const EnfermedadesList({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enfermedadState = ref.watch(enfermedadNotifierProvider);
    final usuariosAsync = ref.watch(obtenerTodosUsuariosProvider);

    // 1. Lógica para obtener nombres de proyectos (para mostrar en la tarjeta)
    final getProyectos = ref.read(getProyectosEnfermedadUseCaseProvider);
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
      error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
      data: (usuarios) {
        
        if (enfermedadState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final enfermedades = enfermedadState.enfermedad;

        if (enfermedades.isEmpty) {
          return _buildEmptyState();
        }

        // 2. Filtrado
        final filteredEnfermedades = searchQuery.isEmpty
            ? enfermedades
            : enfermedades.where((enfermedad) {
                final query = searchQuery.toLowerCase();
                
                // Buscar nombre del usuario
                String nombreUsuario = '';
                try {
                  final u = usuarios.firstWhere((u) => u.id == enfermedad.usuarioId);
                  nombreUsuario = u.nombre.toLowerCase();
                } catch (_) {}

                // Filtramos por Eventualidad o Nombre de Usuario
                // Nota: No filtramos por proyecto texto porque ahora es ID
                return enfermedad.eventualidad.toLowerCase().contains(query) ||
                       nombreUsuario.contains(query);
              }).toList();

        if (filteredEnfermedades.isEmpty) {
          return const Center(
            child: Text(
              'No se encontraron resultados',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredEnfermedades.length,
          itemBuilder: (context, index) {
            final enfermedad = filteredEnfermedades[index];
            
            // Buscar usuario
            String nombreUsuario = "Usuario desconocido";
            String emailUsuario = "";
            try {
              final usuario = usuarios.firstWhere((u) => u.id == enfermedad.usuarioId);
              nombreUsuario = usuario.nombre;
              emailUsuario = usuario.email;
            } catch (_) {}

            // Buscar nombre del proyecto
            String nombreProyecto = "ID: ${enfermedad.proyectoId}";
            if (listaProyectos.value.isNotEmpty) {
              try {
                final p = listaProyectos.value.firstWhere((p) => p['id'] == enfermedad.proyectoId);
                nombreProyecto = p['Nombre'] ?? p['nombre'] ?? nombreProyecto;
              } catch (_) {}
            }

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EnfermedadDetalleScreen(enfermedad: enfermedad),
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
                            backgroundColor: Colors.blue.shade700,
                            radius: 20,
                            child: const Icon(Icons.medical_services, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  enfermedad.eventualidad,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  nombreProyecto, // ✅ Mostramos el nombre del proyecto
                                  style: TextStyle(fontSize: 12, color: Colors.blue.shade800, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yy').format(enfermedad.fechaRegistro),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 8),

                      // Pie de tarjeta (Usuario)
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.black54),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nombre: $nombreUsuario', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                Text(emailUsuario, style: const TextStyle(fontSize: 12, color: Colors.black54), overflow: TextOverflow.ellipsis),
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
            'No hay reportes de enfermedades',
            style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}