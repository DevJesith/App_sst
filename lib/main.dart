import 'package:app_sst/data/database/drop_clean_database.dart';
import 'package:app_sst/features/auth/presentation/screens/check_auth_screen.dart';
import 'package:app_sst/services/connectivity_manager.dart';
import 'package:app_sst/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Punto de entrada principal de la aplicacion
void main() async {

  // 1. Asegurar que el motor de flutter este listo antes de ejecutar codigo asincrono
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Notificaciones
  await NotificationService().initialize();

  // 2. Inicializar el gestor de conectividad (Sincronizacion automatica)
  // Esto comienza a escuchar si hay internet para subir/bajar datos
  ConnectivityManager().initialize();

  // 3. Limpieeza de base de datos 
  await DatabaseResetter.eliminarBD();

  // 4. Ejecutar la aplicacion envuelta en ProviderScopw (Riverpod)
  runApp(ProviderScope(child: AppSST()));


}

/// Wiget raiz de la aplicacion
/// Configura el tema global y la navegacion inicial.
class AppSST extends StatelessWidget {
  const AppSST({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App SST',

      // Quitar la etiqueta DEBUG de la esquina
      debugShowCheckedModeBanner: false,

      // Configuracion del tema global 
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),

      //Pantalla inicial
      home: const CheckAuthScreen(),
    );
  }
}
