// features/auth/presentation/screens/formularios_recibidos_screen.dart

import 'package:app_sst/features/forms/enfermedad/presentation/screens/enfermedad_list.dart';
import 'package:app_sst/features/forms/gestion/presentation/screens/gestion_list.dart';
import 'package:app_sst/features/forms/incidente/presentation/screens/incidente_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../forms/accidente/presentation/providers/accidente_providers.dart';
import '../../../forms/accidente/presentation/screens/accidente_detalle_screen.dart';
import '../providers/auth_provider.dart';
import '../../../forms/accidente/presentation/screens/accidente_list.dart';

/// Pantalla de formularios recibidos con tabs y búsqueda
class FormulariosRecibidosScreen extends HookConsumerWidget {
  const FormulariosRecibidosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final selectedTab = useState(0);

    // Cargar datos al iniciar
    useEffect(() {
      Future.microtask(() {
        ref.read(accidenteNotifierProvider.notifier).loadAccidentes();
      });
      return null;
    }, []);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 231, 231, 231),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          title: const Text(
            'Registros de Formularios',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            // Tabs horizontales
            Container(
              color: Colors.white,
              child: TabBar(
                onTap: (index) => selectedTab.value = index,
                isScrollable: true,
                indicatorColor: Colors.blue,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Accidente'),
                  Tab(text: 'Incidente'),
                  Tab(text: 'Gestión'),
                  Tab(text: 'Enfermedad'),
                  Tab(text: 'Capacitación'),
                ],
              ),
            ),

            // Barra de búsqueda
            Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o correo',
                  hintStyle: const TextStyle(color: Colors.black),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black, width: 5.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black, width: 1.8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                ),
                onChanged: (value) {
                  // Trigger rebuild para filtrar
                  selectedTab.value = selectedTab.value;
                },
              ),
            ),

            // Contenido de las tabs
            Expanded(
              child: TabBarView(
                children: [
                  AccidentesList(searchQuery: searchController.text),
                  IncidenteList(searchQuery: searchController.text),
                  GestionesList(searchQuery: searchController.text),
                  EnfermedadesList(searchQuery: searchController.text),
                  _PlaceholderTab(tipo: 'Capacitación',),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder para otras tabs (Incidente, Gestión, Enfermedad)
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
