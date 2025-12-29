import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

// Imports
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/capacitacion_providers.dart';
import 'capacitacion_detalle_screen.dart';

class CapacitacionesEnviadosScreen extends HookConsumerWidget {
  const CapacitacionesEnviadosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cargar datos al entrar
    useEffect(() {
      Future.microtask(() {
        ref.read(capacitacionNotifierProvider.notifier).loadCapacitaciones();
      });
      return null;
    }, []);

    final usuarioActual = ref.watch(usuarioAutenticadoProvider);
    final capacitacionState = ref.watch(capacitacionNotifierProvider);

    // Filtrar por usuario
    final misCapacitaciones = usuarioActual != null
        ? capacitacionState.capacitaciones
            .where((c) => c.usuarioId == usuarioActual.id)
            .toList()
        : <dynamic>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mis Capacitaciones'),
        backgroundColor: Colors.orange.shade700, // Color temático
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(capacitacionNotifierProvider.notifier).loadCapacitaciones();
            },
          ),
        ],
      ),
      body: capacitacionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : misCapacitaciones.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No has enviado capacitaciones',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // --- HEADER ESTADÍSTICAS (Igual a Accidente) ---
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
                            'Reportes Realizados',
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
                                'Total: ${misCapacitaciones.length}',
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
                        itemCount: misCapacitaciones.length,
                        itemBuilder: (context, index) {
                          final capacitacion = misCapacitaciones[index];
                          final fecha = DateFormat('dd/MM/yyyy').format(capacitacion.fechaRegistro);

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CapacitacionDetalleScreen(capacitacion: capacitacion),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Título y Estado
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            capacitacion.descripcion, // Tema
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: (capacitacion.sincronizado == 1 ? Colors.green : Colors.orange).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: capacitacion.sincronizado == 1 ? Colors.green : Colors.orange),
                                          ),
                                          child: Text(
                                            capacitacion.sincronizado == 1 ? "Enviado" : "Pendiente",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: capacitacion.sincronizado == 1 ? Colors.green : Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Datos
                                    _buildRow(Icons.person, 'Responsable: ${capacitacion.responsable}'),
                                    const SizedBox(height: 8),
                                    _buildRow(Icons.group, 'Asistentes: ${capacitacion.numeroPersonas}'),
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
                                              builder: (_) => CapacitacionDetalleScreen(capacitacion: capacitacion),
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
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87))),
      ],
    );
  }
}