import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

// Imports de Providers y Pantallas
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/gestion_providers.dart';
import 'gestion_detalle_screen.dart';

class GestionesEnviadosScreen extends HookConsumerWidget {
  const GestionesEnviadosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Cargar gestiones al iniciar
    useEffect(() {
      Future.microtask(() {
        ref.read(gestionNotifierProvider.notifier).loadGestiones();
      });
      return null;
    }, []);

    final usuarioActual = ref.watch(usuarioAutenticadoProvider);
    final gestionState = ref.watch(gestionNotifierProvider);

    // 2. Lógica para obtener nombres de proyectos (Nombres Reales)
    final getProyectos = ref.read(getProyectosGestionUseCaseProvider);
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
    final misGestiones = usuarioActual != null
        ? gestionState.gestiones
            .where((g) => g.usuarioId == usuarioActual.id)
            .toList()
        : <dynamic>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mis Gestiones Enviadas'),
        backgroundColor: Colors.green.shade700, // Color Verde
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(gestionNotifierProvider.notifier).loadGestiones();
            },
          ),
        ],
      ),
      body: gestionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : misGestiones.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No has enviado gestiones aún',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // --- HEADER ESTADÍSTICAS (Igual a Enfermedad) ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700, // Verde
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gestiones Reportadas',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.assignment, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Total: ${misGestiones.length}',
                                style: const TextStyle(fontSize: 16, color: Colors.white70),
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
                        itemCount: misGestiones.length,
                        itemBuilder: (context, index) {
                          final gestion = misGestiones[index];
                          final fecha = DateFormat('dd/MM/yyyy').format(gestion.fechaRegistro);

                          // Buscar nombre del proyecto
                          String nombreProyecto = "ID: ${gestion.proyectoId}";
                          if (listaProyectos.value.isNotEmpty) {
                            try {
                              final p = listaProyectos.value.firstWhere((p) => p['id'] == gestion.proyectoId);
                              nombreProyecto = p['Nombre'] ?? p['nombre'] ?? nombreProyecto;
                            } catch (_) {}
                          }

                          return Card(
                            elevation: 2,
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
                                    // Fila Superior: Título (Proyecto) y Badge
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            nombreProyecto, // Nombre Real
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // Badge de Estado (Sincronizado/Pendiente)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: (gestion.sincronizado == 1 ? Colors.green : Colors.orange).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: gestion.sincronizado == 1 ? Colors.green : Colors.orange,
                                            ),
                                          ),
                                          child: Text(
                                            gestion.sincronizado == 1 ? "Sincronizado" : "Pendiente",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: gestion.sincronizado == 1 ? Colors.green : Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Detalles
                                    _buildRow(Icons.emergency, 'EE: ${gestion.ee}'),
                                    const SizedBox(height: 8),
                                    _buildRow(Icons.security, 'EPP: ${gestion.epp}'),
                                    const SizedBox(height: 8),
                                    _buildRow(Icons.calendar_today, 'Fecha: $fecha'),

                                    const SizedBox(height: 12),

                                    // Botón Ver Detalles
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => GestionDetalleScreen(gestion: gestion),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.arrow_forward, size: 16),
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
          child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ),
      ],
    );
  }
}