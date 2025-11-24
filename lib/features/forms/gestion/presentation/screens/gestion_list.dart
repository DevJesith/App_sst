import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/forms/gestion/presentation/providers/gestion_providers.dart';
import 'package:app_sst/features/forms/gestion/presentation/screens/gestion_detalle_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

/// Lista de Gestiones
class GestionesList extends HookConsumerWidget {
  final String searchQuery;

  const GestionesList({required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gestionState = ref.watch(gestionNotifierProvider);
    final usuariosAsync = ref.watch(obtenerTodosUsuariosProvider);

    return usuariosAsync.when(
      data: (usuarios) {
        if (gestionState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final gestiones = gestionState.gestiones;

        if (gestiones.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 80,
                  color: Colors.black,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay reportes de gestiones',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        }

        // Filtrar por búsqueda - CORREGIDO
        final filteredGestiones = searchQuery.isEmpty
            ? gestiones
            : gestiones.where((gestion) {
                try {
                  final usuario = usuarios.firstWhere(
                    (u) => u.id == gestion.usuarioId,
                  );
                  final searchLower = searchQuery.toLowerCase();
                  return usuario.nombre.toLowerCase().contains(searchLower) ||
                      usuario.email.toLowerCase().contains(searchLower);
                } catch (e) {
                  return false;
                }
              }).toList();

        if (filteredGestiones.isEmpty) {
          return Center(
            child: Text(
              'No se encontraron resultados',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredGestiones.length,
          itemBuilder: (context, index) {
            final gestion = filteredGestiones[index];
            
            // Buscar usuario de forma segura - CORREGIDO
            String nombreUsuario = "Usuario desconocido";
            String emailUsuario = "Sin correo";
            
            try {
              final usuario = usuarios.firstWhere(
                (u) => u.id == gestion.usuarioId,
              );
              nombreUsuario = usuario.nombre;
              emailUsuario = usuario.email;
            } catch (e) {
              // Si no encuentra el usuario, usa los valores por defecto
            }
            
            final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm')
                .format(gestion.fechaRegistro);

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GestionDetalleScreen(
                        gestion: gestion,
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
                      // Encabezado con usuario
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.teal.shade700,
                            radius: 20,
                            child: const Icon(
                              Icons.manage_accounts,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  gestion.proyecto,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  fechaFormateada,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      const Divider(color: Colors.grey),

                      const SizedBox(height: 8),

                      // Información del usuario - CORREGIDO
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nombre: $nombreUsuario',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  emailUsuario,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}