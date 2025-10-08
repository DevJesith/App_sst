import 'package:app_sst/features/auth/domain/entities/usuarios.dart';
import 'package:app_sst/features/auth/presentation/screens/introducion_screen.dart';
import 'package:flutter/material.dart';


/// Drawer personalizado que muestra la información del usuario y opciones de navegación.
/// Ideal para apps con múltiples secciones y lógica de sesión.
class CustomDrawer extends StatelessWidget {
  final Usuarios usuarios;
  const CustomDrawer({super.key, required this.usuarios});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: NetworkImage(
                "https://i.pravatar.cc/300",
              ), // Avatar de ejemplo
            ),
            accountName:  Text(usuarios.nombre),
            accountEmail: Text(usuarios.email),
          ),

          // Opciones del menú
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Ver Perfil"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notificaciones"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.send),
            title: const Text("Enviados"),
            onTap: () {},
          ),

          const Spacer(), // Empuja "Cerrar sesión" al fondo

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Cerrar Sesión"),
            onTap: () {
              // Aquí pones tu lógica de logout
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => IntroducionScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
