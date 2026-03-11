import 'package:app_sst/features/auth/presentation/screens/admin/admin_pqrs_screen.dart';
import 'package:app_sst/features/auth/presentation/screens/admin/admin_solicitudes_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../core/utils/exports/export_utils.dart';
import '../../../../../shared/widgets/perfil_widget.dart';
import '../../../domain/entities/usuarios.dart';
import 'usuarios_registrados_screen.dart';
import 'formularios_recibidos_screen.dart';

/// Pantalla principal para el perfil de Administrador
/// 
/// Permite: 
/// 1. Navegar a la gestion de usuarios registrados.
/// 2. Ver los formularios recibidor.
/// 3. Exportar la base de datos y generar reportes PDF
class AdminDashboard extends HookConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Crear un usuario temporal para representar el admin en el Drawer.
    final adminUser = Usuarios(
      id: 0,
      nombre: 'Administrador',
      apellido: 'Sistema',
      email: 'admin@sst.com',
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 247, 250),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Panel de Administración',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),

      // Menu Lateral con permisos de admin activados
      drawer: CustomDrawer(
        usuarios: adminUser,
        esAdmin: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- ENCABEZADO ---
                Text(
                  'Bienvenido, Administrador',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gestiona usuarios y formularios desde aquí',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
            
                // --- SECCION: GESTION ---
                Text(
                  'Gestión',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
            
                // Navegacion a Usuarios
                _DashboardCard(
                  title: 'Usuarios Registrados',
                  subtitle: 'Ver todos los usuarios del sistema',
                  icon: Icons.people,
                  color: Colors.blue.shade700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UsuariosRegistradosScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
            
                // Navegacion a Formularios
                _DashboardCard(
                  title: 'Formularios Recibidos',
                  subtitle: 'Ver todos los reportes enviados',
                  icon: Icons.assignment,
                  color: Colors.purple.shade700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FormulariosRecibidosScreen(),
                      ),
                    );
                  },
                ),
            
                const SizedBox(height: 32),
            
                // --- SECCION: EXPORTACION ---
                Text(
                  'Exportación de Datos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
            
                // Accion: Exportar BD
                _DashboardCard(
                  title: 'Exportar Base de Datos',
                  subtitle: 'Descargar archivo .db para respaldo',
                  icon: Icons.download,
                  color: Colors.green.shade700,
                  onTap: () async {
                    await ExportUtils.exportDatabase(context);
                  },
                ),
                const SizedBox(height: 16),
            
                // Accion: Generar reporte
                _DashboardCard(
                  title: 'Generar Reporte PDF',
                  subtitle: 'Crear PDF con información de la BD',
                  icon: Icons.picture_as_pdf,
                  color: Colors.orange.shade700,
                  onTap: () async {
            
                    // Llama a la utilidad refectorizada con JOINs
                    await ExportUtils.generateDatabasePDF(context);
                  },
                ),

                const SizedBox(height: 16),

                _DashboardCard(
                  title: 'Gestion de PQRS',
                  subtitle: 'Atender peticiones y quejas de usuarios',
                  icon: Icons.feedback,
                  color: Colors.teal.shade700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminPqrsScreen (),
                      ),
                    );
                  },
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget interno para las tarjetas del dashboard
/// Mantiene el codigo principal limpio y reutilizable
class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 230, 230, 230),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icono con fondo coloreado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),

              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Flecha indicadora
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}