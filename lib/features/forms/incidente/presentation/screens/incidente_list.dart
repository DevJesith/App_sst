import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/incidente_providers.dart';
import 'incidente_detalles_screen.dart';

class IncidenteList extends HookConsumerWidget {
  final String searchQuery;

  const IncidenteList({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidenteState = ref.watch(incidenteNotifierProvider);
    final usuariosAsync = ref.watch(obtenerTodosUsuariosProvider);

    // Cargar proyectos para nombres reales
    final getProyectos = ref.read(getProyectosIncidenteUseCaseProvider);
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
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (usuarios) {
        if (incidenteState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final incidentes = incidenteState.incidentes;

        if (incidentes.isEmpty) {
          return _buildEmptyState();
        }

        // Filtrado
        final filteredIncidentes = searchQuery.isEmpty
            ? incidentes
            : incidentes.where((incidente) {
                final query = searchQuery.toLowerCase();
                String nombreUsuario = '';
                try {
                  final u = usuarios.firstWhere(
                    (u) => u.id == incidente.usuarioId,
                  );
                  nombreUsuario = u.nombre.toLowerCase();
                } catch (_) {}

                return incidente.eventualidad.toLowerCase().contains(query) ||
                    nombreUsuario.contains(query);
              }).toList();

        if (filteredIncidentes.isEmpty) {
          return const Center(child: Text('No se encontraron resultados'));
        }

        return Column(
          children: [
            // --- HEADER ESTADÍSTICAS ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Incidentes Registrados',
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
                        'Total: ${filteredIncidentes.length}',
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

            // --- LISTA ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredIncidentes.length,
                itemBuilder: (context, index) {
                  final incidente = filteredIncidentes[index];

                  String nombreUsuario = "Usuario desconocido";
                  String emailUsuario = "";
                  try {
                    final u = usuarios.firstWhere(
                      (u) => u.id == incidente.usuarioId,
                    );
                    nombreUsuario = u.nombre;
                    emailUsuario = u.email;
                  } catch (_) {}

                  String nombreProyecto = "ID: ${incidente.proyectoId}";
                  if (listaProyectos.value.isNotEmpty) {
                    try {
                      final p = listaProyectos.value.firstWhere(
                        (p) => p['id'] == incidente.proyectoId,
                      );
                      nombreProyecto =
                          p['Nombre'] ?? p['nombre'] ?? nombreProyecto;
                    } catch (_) {}
                  }

                  final fecha = DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(incidente.fechaRegistro);

                  return Card(
                    elevation: 2,
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
                                IncidenteDetallesScreen(incidente: incidente),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.orange.shade700,
                                  child: const Icon(
                                    Icons.report_problem,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        incidente.eventualidad,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        nombreProyecto,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'dd/MM/yy',
                                  ).format(incidente.fechaRegistro),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nombre: $nombreUsuario',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        emailUsuario,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
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
            'No hay reportes de incidentes',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
