import 'package:app_sst/features/notifications/presentation/providers/notification_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

/// Widget que muestra el listado del historial de notificaciones.
///
/// Incluye:
/// * Visualización de alertas marcadas como leídas y no leídas (por colores).
/// * Opción en la barra superior (AppBar) para eliminar todo el historial.
/// * Parseo automático del texto del cuerpo para renderizar viñetas.
/// 
/// Utiliza `HookConsumerWidget` (Hooks Riverpod) para escuchar el estado 
/// en tiempo real y reaccionar al ciclo de vida.
class NotificacionesScreen extends HookConsumerWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Observamos el estado actual (la lista de notificaciones)
    final notificaciones = ref.watch(notificationNotifierProvider);
    // 2. Accedemos a los metodos para ejecutar acciones del estado
    final notifier = ref.read(notificationNotifierProvider.notifier);

    // Efecto secundario: Al abrir la pantalla, se marca todo como leido automaticamente.
    useEffect(() {
      Future.microtask(() => notifier.marcarComoLeidas());
      return null;
    }, []);

    // 3. Construccion de la pantalla principal
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Boton de eliminar, solo visible si hay notificaciones
          if (notificaciones.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("¿Borrar todo?"),
                    content: const Text(
                      "Se eliminara el historial de notificaciones.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed: () {
                          notifier.limpiar();
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          "Borrar",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              tooltip: "Borrar todo",
            ),
        ],
      ),
      body: notificaciones.isEmpty
          // 4. Estado vacio (Sin notificaciones)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "No tienes notificaciones",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          // 5. Construccion de la lista de notificaciones (Tarjetas)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notificaciones.length,
              itemBuilder: (context, index) {
                final item = notificaciones[index];
                
                return Card(
                  elevation: 0,
                  // Cambiamos el color completo de la tarjeta si es nueva
                  color: item.leido ? Colors.white : Colors.blue.shade500,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Encabezado: Icono
                        CircleAvatar(
                          backgroundColor: item.leido
                              ? Colors.grey.shade200
                              : Colors.blue,
                          child: Icon(
                            Icons.cloud_upload,
                            color: item.leido ? Colors.blue : Colors.white,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Textos descriptivos
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Titulo y hora de registro a la derecha
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.titulo,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,

                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('HH:mm').format(item.fecha),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // CUERPO DETALLADO (Renderizando como viñetas)
                              ...item.cuerpo.split('\n').map((linea) {
                                if (!linea.trim().startsWith('•')) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(
                                      linea,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }

                                // Renderizar items con viñeta real en lugar del caracter '•'
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 4,
                                    left: 4,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          top: 6,
                                          right: 8,
                                        ),
                                        child: CircleAvatar(
                                          radius: 3,
                                          backgroundColor: Colors.black54,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          linea.replaceFirst('• ', '').trim(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              const SizedBox(height: 8),
                              
                              // Pie de tarjeta principal: Fecha del dia
                              Text(
                                DateFormat('dd MMM yyyy').format(item.fecha),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
