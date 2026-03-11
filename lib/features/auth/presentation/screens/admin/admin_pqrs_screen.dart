import 'package:app_sst/features/pqrs/presentation/providers/pqrs_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class AdminPqrsScreen extends HookConsumerWidget {
  const AdminPqrsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listaPqrs = ref.watch(pqrsNotifierProvider);
    final notifier = ref.read(pqrsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Gestion de PQRS')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: listaPqrs.isEmpty
              ? const Center(child: Text("No hay PQRS registradas"))
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
                        leading: Icon(
                          isResuelto
                              ? Icons.check_circle
                              : Icons.pending_actions,
                          color: isResuelto ? Colors.green : Colors.orange,
                        ),
                        title: Text(
                          "${item.tipo} - ${item.nombreSolicitante}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(item.fechaCreacion),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Correo: ${item.correoContacto}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 10),
                                const Text(
                                  "Descripcion:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                Text(item.descripcion),

                                const SizedBox(height: 20),

                                if (!isResuelto)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          notifier.resolver(item.id!),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        "Marcar como Resuelto",
                                        style: TextStyle(color: Colors.white),
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
