import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

// Imports de Providers y Pantallas
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/gestion_providers.dart';
import 'gestion_detalle_screen.dart';

/// Widget que muestra el listado de gestiones de inspección registradas.
class GestionesList extends HookConsumerWidget {
  final String searchQuery;

  const GestionesList({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gestionState = ref.watch(gestionNotifierProvider);
    final usuariosAsync = ref.watch(obtenerTodosUsuariosProvider);
    
    // 1. Lógica para obtener nombres de proyectos
    final getProyectos = ref.read(getProyectosGestionUseCaseProvider);
    final listaProyectos = useState<List<Map<String, dynamic>>>([]);

    useEffect(() {
      Future.microtask(() async {
        try {
          final proyectos = await getProyectos();
          listaProyectos.value = proyectos;
        } catch (e) {
          debugPrint("Error cargando proyectos en lista: $e");
        }
      });
      return null;
    }, []);

    return usuariosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
      data: (usuarios) {
        
        if (gestionState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final gestiones = gestionState.gestiones;

        if (gestiones.isEmpty) {
          return _buildEmptyState();
        }

        // 2. Filtrado
        final filteredGestiones = searchQuery.isEmpty
            ? gestiones
            : gestiones.where((gestion) {
                final query = searchQuery.toLowerCase();
                
                String nombreUsuario = '';
                try {
                  final u = usuarios.firstWhere((u) => u.id == gestion.usuarioId);
                  nombreUsuario = u.nombre.toLowerCase();
                } catch (_) {}

                return gestion.ee.toLowerCase().contains(query) ||
                       nombreUsuario.contains(query);
              }).toList();

        if (filteredGestiones.isEmpty) {
          return const Center(
            child: Text(
              'No se encontraron resultados',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // ✅ ESTRUCTURA CON HEADER DE ESTADÍSTICAS (Igual que Enfermedad/Accidente)
        return Column(
          children: [
            // --- HEADER CON CANTIDAD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade700, // Color temático de Gestión
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestiones Registradas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.assignment,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Total: ${filteredGestiones.length} reporte${filteredGestiones.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- LISTA SCROLLABLE ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredGestiones.length,
                itemBuilder: (context, index) {
                  final gestion = filteredGestiones[index];
                  
                  // Buscar usuario
                  String nombreUsuario = "Usuario desconocido";
                  String emailUsuario = "";
                  try {
                    final usuario = usuarios.firstWhere((u) => u.id == gestion.usuarioId);
                    nombreUsuario = usuario.nombre;
                    emailUsuario = usuario.email;
                  } catch (_) {}

                  // Buscar nombre del proyecto
                  String nombreProyecto = "ID: ${gestion.proyectoId}";
                  if (listaProyectos.value.isNotEmpty) {
                    try {
                      final proyectoObj = listaProyectos.value.firstWhere(
                        (p) => p['id'] == gestion.proyectoId,
                        orElse: () => {'Nombre': 'Desconocido'},
                      );
                      nombreProyecto = proyectoObj['Nombre'] ?? proyectoObj['nombre'] ?? 'Sin nombre';
                    } catch (_) {}
                  }
                  
                  final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(gestion.fechaRegistro);

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GestionDetalleScreen(gestion: gestion),
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
                                  backgroundColor: Colors.teal.shade700,
                                  radius: 20,
                                  child: const Icon(Icons.manage_accounts, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nombreProyecto, // Nombre real
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        fechaFormateada,
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                    ],
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
                                const Icon(Icons.person, size: 16, color: Colors.black54),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Nombre: $nombreUsuario', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                      const SizedBox(height: 2),
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
              ),
            ),
          ],
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
            'No hay reportes de gestiones',
            style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}