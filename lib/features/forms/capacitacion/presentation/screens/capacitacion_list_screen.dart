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

    // Cargar proyectos para mostrar nombres realies
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
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (usuarios) {
        if (capacitacionState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final capacitaciones = capacitacionState.capacitaciones;

        if (capacitaciones.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.school_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay capacitaciones registradas',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Filtrado
        final filteredList = searchQuery.isEmpty
            ? capacitaciones
            : capacitaciones.where((cap) {
                final query = searchQuery.toLowerCase();
                return cap.descripcion.toLowerCase().contains(query) ||
                    cap.responsable.toLowerCase().contains(query);
              }).toList();

        if (filteredList.isEmpty) {
          return const Center(child: Text('No se encontraron resultados'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final cap = filteredList[index];
            final fecha = DateFormat('dd/MM/yyyy').format(cap.fechaRegistro);

            // Buscar nombre del proyecto
            String nombreProyecto = "ID: ${cap.idProyecto}";
            if (listaProyectos.value.isEmpty) {
              try {
                final p = listaProyectos.value.firstWhere(
                  (p) => p['id'] == cap.idProyecto,
                );
              } catch (_) {}
            }

            return Card(
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
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.orange.shade700,
                            child: const Icon(
                              Icons.school,
                              color: Colors.white,
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
                            fecha,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
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
}
