import 'package:app_sst/features/pqrs/presentation/providers/pqrs_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

/// Pantalla de Gestion Administrativa de PQRS
///
/// Permite al Administrador visualizar todas las Peticiones enviadas por los usuarios
class AdminPqrsScreen extends HookConsumerWidget {
  const AdminPqrsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escuchar la lista global de PQRS
    final listaPqrs = ref.watch(pqrsNotifierProvider);
    final notifier = ref.read(pqrsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Gestion de PQRS'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        // Diseño Responsivo
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: listaPqrs.isEmpty
              // --- ESTADO VACIO ---
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 80,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No hay PQRS registradas",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              // --- LISTA DE PQRS ---
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listaPqrs.length,
                  itemBuilder: (context, index) {
                    final item = listaPqrs[index];
                    final isResuelto = item.estado == 'Resuelto';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: isResuelto ? Colors.green : Colors.orange,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        // Icono principal
                        leading: Icon(
                          isResuelto
                              ? Icons.check_circle
                              : Icons.pending_actions,
                          color: isResuelto ? Colors.green : Colors.orange,
                        ),

                        // Titulo (tipo y nombre)
                        title: Text(
                          "${item.tipo} - ${item.nombreSolicitante}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        // Subtitulo (fecha)
                        subtitle: Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(item.fechaCreacion),
                        ),

                        // --- DETALLES DESPLEGABLES ---
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                // Datos de contacto
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email_outlined,
                                      size: 18,
                                      color: Colors.blueGrey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Correo: ${item.correoContacto}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_outlined,
                                      size: 18,
                                      color: Colors.blueGrey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Telefono: ${item.telefonoContacto}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(),
                                ),

                                // Descripcion del problema
                                const Text(
                                  "Descripcion detallada:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  item.descripcion,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // --- BOTON DE ACCION ---
                                if (!isResuelto)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        // Dialogo ed confirmacion de seguridad
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text(
                                              "¿Marcar como Resuelto?",
                                            ),
                                            content: const Text(
                                              "Asegurate de haber contactadao al usuario y solucionado su inconveniente antes de cerrar este ticket",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text(
                                                  "Cancelar",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  notifier.resolver(item.id!);
                                                  Navigator.pop(ctx);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Ticket cerrado exitosamente',
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                ),
                                                child: const Text(
                                                  "SÍ, marcar resuelto",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        "Marcar como Resuelto",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
