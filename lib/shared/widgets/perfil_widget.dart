// shared/widgets/perfil_widget.dart

import 'package:app_sst/features/forms/accidente/presentation/screens/accidente_enviados_screen.dart';
import 'package:app_sst/features/forms/enfermedad/presentation/screens/enfermedad_enviados_screen.dart';
import 'package:app_sst/features/forms/gestion/presentation/screens/gestion_enviados_screen.dart';
import 'package:app_sst/features/forms/incidente/presentation/screens/incidente_enviados_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_sst/features/auth/domain/entities/usuarios.dart';
import 'package:app_sst/features/auth/presentation/screens/introducion_screen.dart';
import 'package:app_sst/features/auth/presentation/screens/usuarios_registrados_screen.dart';
import 'package:app_sst/features/auth/presentation/screens/formularios_recibidos_screen.dart';

/// Drawer personalizado para usuarios y administrador - RESPONSIVE
class CustomDrawer extends StatelessWidget {
  final Usuarios usuarios;
  final bool esAdmin;

  const CustomDrawer({
    super.key,
    required this.usuarios,
    this.esAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener ancho de pantalla para hacer responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth > 600 ? 350.0 : 280.0;

    return Drawer(
      width: drawerWidth,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header del drawer - RESPONSIVE
            _buildHeader(context),

            // Contenido scrollable
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Opciones comunes
                  _buildMenuItem(
                    icon: Icons.person,
                    iconColor: esAdmin ? Colors.purple : Colors.blue,
                    title: "Mi Perfil",
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidad en desarrollo'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 1),

                  // Opciones específicas del ADMIN
                  if (esAdmin) ...[
                    _buildSectionHeader('Panel de Control'),
                    _buildMenuItem(
                      icon: Icons.people,
                      iconColor: Colors.blue,
                      title: "Usuarios Registrados",
                      subtitle: "Ver todos los usuarios",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UsuariosRegistradosScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.assignment,
                      iconColor: Colors.purple,
                      title: "Formularios Recibidos",
                      subtitle: "Ver todos los reportes",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FormulariosRecibidosScreen(),
                          ),
                        );
                      },
                    ),
                  ],

                  // Opciones específicas del USUARIO NORMAL
                  if (!esAdmin) ...[
                    _buildSectionHeader('Mis Formularios Enviados'),
                    
                    _buildMenuItem(
                      icon: Icons.warning_amber,
                      iconColor: Colors.red,
                      title: "Accidentes",
                      subtitle: "Ver reportes de accidentes",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AccidentesEnviadosScreen(),
                          ),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.error_outline,
                      iconColor: Colors.orange,
                      title: "Incidentes",
                      subtitle: "Ver reportes de incidentes",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const IncidentesEnviadosScreen(),
                          ),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.medical_services,
                      iconColor: Colors.purple,
                      title: "Enfermedades Laborales",
                      subtitle: "Ver reportes de enfermedades",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EnfermedadesEnviadosScreen(),
                          ),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.checklist,
                      iconColor: Colors.green,
                      title: "Gestiones",
                      subtitle: "Ver gestiones de inspección",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GestionesEnviadosScreen(),
                          ),
                        );
                      },
                    ),

                    const Divider(height: 1),

                    _buildMenuItem(
                      icon: Icons.notifications,
                      iconColor: Colors.blue,
                      title: "Notificaciones",
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Funcionalidad en desarrollo'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Botón de cerrar sesión al fondo
            const Divider(height: 1),
            _buildLogoutButton(context),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: esAdmin
              ? [Colors.purple.shade600, Colors.purple.shade800]
              : [Colors.blue.shade600, Colors.blue.shade800],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: isWide ? 80 : 70,
            height: isWide ? 80 : 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                esAdmin ? Icons.admin_panel_settings : Icons.person,
                size: isWide ? 40 : 35,
                color: esAdmin ? Colors.purple.shade700 : Colors.blue.shade700,
              ),
            ),
          ),
          SizedBox(height: isWide ? 16 : 12),

          // Nombre
          Row(
            children: [
              Expanded(
                child: Text(
                  usuarios.nombre,
                  style: TextStyle(
                    fontSize: isWide ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (esAdmin)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ADMIN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            usuarios.email,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cerrar Sesión'),
            content: const Text(
              '¿Estás seguro de que deseas cerrar sesión?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const IntroducionScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.red,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Cerrar Sesión",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}