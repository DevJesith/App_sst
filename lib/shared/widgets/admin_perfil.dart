import 'package:app_sst/features/forms/accidente/presentation/screens/accidente_enviados_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_sst/features/auth/domain/entities/usuarios.dart';
import 'package:app_sst/features/auth/presentation/screens/introducion_screen.dart';


/// Drawer personalizado que muestra la información del usuario y opciones de navegación.
class CustomDrawerAdmin extends StatelessWidget {

  const CustomDrawerAdmin({super.key,});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header del drawer con info del usuario
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade700,
                  Colors.blue.shade900,
                ],
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                'Admin',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            accountName: Text(
              'Admin',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              'admin@sst',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),

          // Opciones del menú
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text("Ver Perfil"),
            onTap: () {
              // TODO: Implementar pantalla de perfil
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad en desarrollo'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          
          const Divider(),

          // ✅ NUEVA OPCIÓN: Ver formularios enviados
          ListTile(
            leading: const Icon(Icons.assignment, color: Colors.green),
            title: const Text("Formularios Recibidos"),
            subtitle: const Text("Ver reportes de todos los usuarios"),
            onTap: () {
              Navigator.pop(context); // Cerrar drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccidentesEnviadosScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.orange),
            title: const Text("Usuarios registrados"),
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

          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.orange),
            title: const Text("Notificaciones"),
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

          const Spacer(), // Empuja "Cerrar sesión" al fondo

          const Divider(),

          // Botón de cerrar sesión
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Cerrar Sesión",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              // Mostrar diálogo de confirmación
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
                        Navigator.pop(context); // Cerrar diálogo
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
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}