import 'package:app_sst/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_sst/features/notifications/presentation/providers/notification_providers.dart';
import 'package:app_sst/features/notifications/presentation/screens/notificaciones_screen.dart';
import 'package:app_sst/services/connectivity_manager.dart';
import 'package:app_sst/shared/widgets/perfil_widget.dart';
import 'package:app_sst/features/auth/domain/entities/usuarios.dart';
import 'package:app_sst/features/forms/gestion/presentation/screens/gestion_form.dart';
import 'package:app_sst/features/home/presentation/home_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
  final Usuarios usuario ;
  const WelcomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarioState = ref.watch(usuarioAutenticadoProvider);

    final usuarioActual = usuarioState ?? usuario;

    useEffect(() {
      ConnectivityManager().onSyncCompleted = () {
        ref.read(notificationNotifierProvider.notifier).cargar();
      };

      return () {
        ConnectivityManager().onSyncCompleted = null;
      };
    }, []);

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
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final notificaciones = ref.watch(notificationNotifierProvider);
              final noLeidas = notificaciones.where((n) => !n.leido).length;

              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {
                      ref
                          .read(notificationNotifierProvider.notifier)
                          .marcarLeidas();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificacionesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.black87,
                      size: 30,
                    ),
                  ),
                  if (noLeidas > 0)
                    Positioned(
                      right: 8,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFF5F7FA), width: 2.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 22,
                          minHeight: 22,
                        ),
                        child: Text(
                          noLeidas > 99 ? '99+' : '$noLeidas',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            height: 1
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),

      /// Menu lateral con la informacion del usuario actual
      drawer: CustomDrawer(usuarios: usuarioActual),

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
                      "¡Hola, ${usuarioActual.nombre.split(' ')[0]}! ",
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreens(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: CupertinoColors.activeBlue,
                        ),
                        child: const Text(
                          'Reportar Riesgos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Boton: Gestion de formularios
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GestionFormScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: const Color.fromARGB(
                            255,
                            0,
                            168,
                            42,
                          ),
                        ),
                        child: const Text(
                          'Gestión de Inspección',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
