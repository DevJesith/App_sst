import 'package:app_sst/features/forms/capacitacion/presentation/providers/capacitacion_providers.dart';
import 'package:app_sst/features/forms/capacitacion/presentation/screens/capacitacion_list_screen.dart';
import 'package:app_sst/features/forms/enfermedad/presentation/screens/enfermedad_list.dart';
import 'package:app_sst/features/forms/gestion/presentation/providers/gestion_providers.dart';
import 'package:app_sst/features/forms/gestion/presentation/screens/gestion_list.dart';
import 'package:app_sst/features/forms/incidente/presentation/providers/incidente_providers.dart';
import 'package:app_sst/features/forms/incidente/presentation/screens/incidente_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../forms/accidente/presentation/providers/accidente_providers.dart';
import '../../../../forms/accidente/presentation/screens/accidente_list.dart';

/// Pantalla que centraliza la visualizacion de todos los formularios enviados.
///
/// Utiliza un [DefaultTabController] para navegar entre diferentes tipos de reportes (Accidente, Incidente, Capacitacion, etc.).
class FormulariosRecibidosScreen extends HookConsumerWidget {
  const FormulariosRecibidosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controlador para la barra de busqueda
    final searchController = useTextEditingController();
    //Estado para forzar la reconstruccion al buscar
    final searchQuery = useState('');

    // Cargar datos al iniciar
    useEffect(() {
      Future.microtask(() {
        ref.read(accidenteNotifierProvider.notifier).loadAccidentes();
        ref.read(incidenteNotifierProvider.notifier).loadIncidentes();
        ref.read(gestionNotifierProvider.notifier).loadGestiones();
        // ref.read(enfermedadNotifierProvider).loadEnfermedades(),
        ref.read(capacitacionNotifierProvider.notifier).loadCapacitaciones();
      });
      return null;
    }, []);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          title: const Text(
            'Registros de Formularios',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              color: Colors.white,
              child: TabBar(
                isScrollable: true,
                indicatorColor: Colors.blue.shade700,
                labelColor: Colors.blue.shade700,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Accidente'),
                  Tab(text: 'Incidente'),
                  Tab(text: 'Gestion'),
                  Tab(text: 'Enfermedad'),
                  Tab(text: 'Capacitacion'),
                ],
              ),
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // --- BARRA DE BUSQUEDA ---
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o correo',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      //Actualizamos el estado para que los hijos se reconstruyan con el filtro
                      searchQuery.value = value;
                    },
                  ),
                ),
            
                // Contenido de las tabs
                Expanded(
                  child: TabBarView(
                    children: [
                      //1. Accidentes
                      AccidentesList(searchQuery: searchQuery.value),
            
                      // 2. Incidentes
                      IncidenteList(searchQuery: searchQuery.value),
            
                      // 3. Gestion
                      GestionesList(searchQuery: searchQuery.value),
            
                      // 4. Enfermedad
                      EnfermedadesList(searchQuery: searchController.text),
            
                      // 5. Capacitacion
                      CapacitacionListScreen(searchQuery: searchController.text)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget temporal para mostrar en tabs que aun no tienen lista implementada
class _PlaceholderTab extends StatelessWidget {
  final String tipo;

  const _PlaceholderTab({required this.tipo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 80, color: Colors.black),
          const SizedBox(height: 16),
          Text(
            'Formularios de $tipo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
