import 'package:app_sst/shared/widgets/boton_navegacion_widgets.dart';
import 'package:app_sst/shared/widgets/perfil_widget.dart';
import 'package:app_sst/features/auth/domain/entities/usuarios.dart';
import 'package:app_sst/features/forms/gestion/presentation/screens/gestion_form.dart';
import 'package:app_sst/features/home/presentation/home_screens.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Pantalla de bienvenida
///
/// Se muestra inmediatamente despues de un inicio de sesion existoso.
/// Funciona como el menu principal para acceder a:
/// 1. Reporte de riesgos (Grid de formularios).
/// 2. Gestion de inspeccion.
/// 3. Menu lateral (Drawer) con informacion del perfil
class WelcomeScreen extends HookConsumerWidget {
  /// El usuario autenticado que ha iniciado sesion.
  final Usuarios usuario;
  const WelcomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      /// AppBar personalizado
      /// Usamos un [Builder] para obtener el contexto correcto y poder abrir el Drawer
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: Icon(Icons.menu, color: Colors.black87),
          ),
        ),
      ),

      /// Menu lateral con la informacion del usuario actual
      drawer: CustomDrawer(usuarios: usuario),

      /// Cuerpo responsive
      /// Usa [LayoutBuilder] para centrar el contenido en pantallas grandes (Tablets/Web)
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
                    // 1. LOGO
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
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

                    /// 2. SALUDO PERSONALIZADO
                    Text(
                      "¡Hola, ${usuario.nombre.split(' ')[0]}! ",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    /// 3. DESCRIPCION
                    const Text(
                      "Ya estás dentro del sistema.\nDesde aquí puedes reportar riesgos, gestionar formularios y mantener tu entorno laboral seguro.",
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    /// 4. BOTONES DE ACCION PRINCIPAL

                    /// Boton: Reportar riesgos
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

                    /// Boton: Gestion de formularios
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
