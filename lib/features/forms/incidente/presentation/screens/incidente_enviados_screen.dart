import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

// Imports
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/incidente_providers.dart';
import 'incidente_detalles_screen.dart';

class IncidentesEnviadosScreen extends HookConsumerWidget {
  const IncidentesEnviadosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Cargar incidentes
    useEffect(() {
      Future.microtask(() {
        ref.read(incidenteNotifierProvider.notifier).loadIncidentes();
      });
      return null;
    }, []);

    final usuarioActual = ref.watch(usuarioAutenticadoProvider);
    final incidenteState = ref.watch(incidenteNotifierProvider);

    // 2. Cargar proyectos para nombres reales
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

    // 3. Filtrar por usuario
    final misIncidentes = usuarioActual != null
        ? incidenteState.incidentes
              .where((i) => i.usuarioId == usuarioActual.id)
              .toList()
        : <dynamic>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mis Incidentes Enviados'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: incidenteState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : misIncidentes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No has enviado incidentes aún',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : Column(
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
                        'Incidentes Reportados',
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
                            'Total: ${misIncidentes.length}',
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
                    itemCount: misIncidentes.length,
                    itemBuilder: (context, index) {
                      final incidente = misIncidentes[index];
                      final fecha = DateFormat(
                        'dd/MM/yyyy',
                      ).format(incidente.fechaRegistro);

                      // Buscar nombre del proyecto
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
                                builder: (_) => IncidenteDetallesScreen(
                                  incidente: incidente,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título y Badge
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        incidente.eventualidad,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white, // Fondo blanco
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          // ✅ AQUÍ ESTÁ LA MAGIA DEL BORDE
                                          color: incidente.sincronizado == 1
                                              ? Colors
                                                    .green // Verde si está completo
                                              : Colors
                                                    .red, // Rojo si está incompleto
                                          width: 2.0, // Grosor del borde
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            incidente.sincronizado == 1
                                                ? Icons
                                                      .thumb_up_alt_outlined // Dedito arriba (Completo)
                                                : Icons
                                                      .circle_outlined, // Círculo (Incompleto)
                                            size: 16,
                                            color: incidente.sincronizado == 1
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            incidente.sincronizado == 1
                                                ? "Completa"
                                                : "Incompleta",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: incidente.sincronizado == 1
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Detalles
                                _buildRow(
                                  Icons.business,
                                  'Proyecto: $nombreProyecto',
                                ),
                                const SizedBox(height: 8),
                                _buildRow(
                                  Icons.calendar_today,
                                  'Fecha: $fecha',
                                ),

                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              IncidenteDetallesScreen(
                                                incidente: incidente,
                                              ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                    ),
                                    label: const Text('Ver detalles'),
                                  ),
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
            ),
    );
  }

  Widget _buildRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
