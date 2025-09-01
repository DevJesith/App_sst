import 'package:app_sst/data/database/drop_clean_database.dart';
import 'package:app_sst/features/auth/presentation/screens/introducion_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
//mport 'package:app_sst/data/database/drop_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await eliminarBD();
  runApp(ProviderScope(child: AppSST()));
}

class AppSST extends StatelessWidget {
  const AppSST({super.key});

  @override
  Widget build(BuildContext context) {
    print('🟢 AppSST build ejecutado');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IntroducionScreen(),
    );
  }
}
