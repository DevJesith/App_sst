// features/forms/gestion/presentation/screens/gestiones_enviados_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/gestion_providers.dart';
import 'gestion_detalle_screen.dart';

/// Pantalla que muestra todas las gestiones enviadas por el usuario actual
class GestionesEnviadosScreen extends HookConsumerWidget {
  const GestionesEnviadosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cargar gestiones cuando se monta el widget
    useEffect(() {
      Future.microtask(() {
        ref.read(gestionNotifierProvider.notifier).loadGestiones();
      });
      return null;
    }, []);

    // Obtener el usuario autenticado
    final usuarioActual = ref.watch(usuarioAutenticadoProvider);

    // Observar el estado de gestiones
    final gestionState = ref.watch(gestionNotifierProvider);

    // Filtrar solo las gestiones del usuario actual
    final misGestiones = usuarioActual != null
        ? gestionState.gestiones
              .where((g) => g.usuarioId == usuarioActual.id)
              .toList()
        : <dynamic>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mis Gestiones Enviadas'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: () {
              ref.read(gestionNotifierProvider.notifier).loadGestiones();
            },
          ),
        ],
      ),
      body: gestionState.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando gestiones...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : misGestiones.isEmpty
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
                    'No has enviado gestiones aún',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tus gestiones de inspección aparecerán aquí',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con estadísticas
                Container(
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
                          const Icon(
                            Icons.assignment,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Total: ${misGestiones.length} gestión${misGestiones.length != 1 ? 'es' : ''}',
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

                // Lista de gestiones
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: misGestiones.length,
                    itemBuilder: (context, index) {
                      final gestion = misGestiones[index];
                      final fechaFormateada = DateFormat(
                        'dd/MM/yyyy',
                      ).format(gestion.fechaRegistro);

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
                                    GestionDetalleScreen(gestion: gestion),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Encabezado con proyecto
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        gestion.proyecto,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getCumpleColor(
                                          gestion.gestionCumple,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: _getCumpleColor(
                                            gestion.gestionCumple,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            gestion.gestionCumple
                                                            .toLowerCase() ==
                                                        'sí' ||
                                                    gestion.gestionCumple
                                                            .toLowerCase() ==
                                                        'si'
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            size: 14,
                                            color: _getCumpleColor(
                                              gestion.gestionCumple,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            gestion.gestionCumple,
                                            style: TextStyle(
                                              color: _getCumpleColor(
                                                gestion.gestionCumple,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Información del EE
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.emergency,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'EE: ${gestion.ee}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // EPP
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.security,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'EPP: ${gestion.epp}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Fecha
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Fecha: $fechaFormateada',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Botón de ver más
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => GestionDetalleScreen(
                                            gestion: gestion,
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

  Color _getCumpleColor(String cumple) {
    if (cumple.toLowerCase() == 'sí' || cumple.toLowerCase() == 'si') {
      return Colors.green;
    }
    return Colors.red;
  }
}
