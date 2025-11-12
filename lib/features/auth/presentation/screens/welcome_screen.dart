import 'package:app_sst/shared/widgets/boton_navegacion_widgets.dart';
import 'package:app_sst/shared/widgets/perfil_widget.dart';
import 'package:app_sst/features/auth/domain/entities/usuarios.dart';
import 'package:app_sst/features/forms/gestion/presentation/screens/gestion_form.dart';
import 'package:app_sst/features/home/presentation/home_screens.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Pantalla de bienvenida para usuarios verificados.
/// Muestra acceso a funcionalidades clave como reportes y formularios.
class WelcomeScreen extends HookConsumerWidget {
  final Usuarios usuario; // Usuario autenticado
  const WelcomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      /// AppBar con botón para abrir el Drawer
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: Icon(Icons.menu),
          ),
        ),
      ),

      /// Drawer personalizado con información del usuario
      drawer: CustomDrawer(usuarios: usuario),
      backgroundColor: const Color(0xFFF5F7FA),

      /// Layout adaptable según ancho de pantalla
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 500 : double.infinity,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          // BoxShadow(
                          //   color: Colors.black.withOpacity(0.15),
                          //   blurRadius: 12,
                          //   offset: const Offset(0, 6),
                          // ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          "assets/images/icono_logo.png",
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Saludo personalizado
                    Text(
                      "¡Hola! 👋",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    /// Mensaje de bienvenida
                    const Text(
                      "Ya estás dentro del sistema.\nDesde aquí puedes reportar riesgos, gestionar formularios y mantener tu entorno laboral seguro.",
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    /// Botón para ir a reportar riesgos
                    BotonNavegacion(
                      text: "Reportar Riesgos",
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeScreens(),
                          ),
                        );
                      },
                      color: Colors.blue.shade700,
                      paddingHorizontal: 50,
                    ),

                    const SizedBox(height: 16),

                    /// Botón para ir a gestión de formularios
                    BotonNavegacion(
                      text: "Gestión de Formularios",
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GestionFormScreen(),
                          ),
                        );
                      },
                      color: Colors.green.shade700,
                      paddingHorizontal: 40,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
