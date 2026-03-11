import 'package:app_sst/features/pqrs/domain/entitie/pqrs.dart';
import 'package:app_sst/features/pqrs/presentation/providers/pqrs_providers.dart';
import 'package:app_sst/shared/widgets/inputs_widgets.dart';
import 'package:app_sst/shared/widgets/lista_input_wigets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PqrsFormScreen extends HookConsumerWidget {
  const PqrsFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final tipoController = useState<String?>(null);
    final nombreController = useTextEditingController();
    final correoController = useTextEditingController();
    final descripcionController = useTextEditingController();

    final isLoading = useState(false);

    final tiposPqrs = ["Peticion", "Queja", "Reclamo", "Sugerencia"];

    Future<void> enviarPqrs() async {
      if (!formKey.currentState!.validate() || tipoController.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor completa todos los campos requeridos'),
          ),
        );
        return;
      }

      isLoading.value = true;
      try {
        final nuevaPqrs = Pqrs(
          tipo: tipoController.value!,
          nombreSolicitante: nombreController.text.trim(),
          correoContacto: correoController.text.trim(),
          descripcion: descripcionController.text.trim(),
          fechaCreacion: DateTime.now(),
        );

        await ref.read(pqrsNotifierProvider.notifier).enviarNueva(nuevaPqrs);

        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Text('PQRS Enviada'),
                ],
              ),
              content: const Text(
                'Hemos recibido tu solicitud. Nos pondremos en contacto contigo pronto.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (context.mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Radicar PQRS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Icon(
                        Icons.feedback_outlined,
                        size: 60,
                        color: Colors.blueGrey,
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Centro de Atencion',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    ListaInputWigets(
                      label: 'Tipo de Solicitud',
                      nameInput: 'Selecciona una opcion',
                      items: tiposPqrs,
                      value: tipoController.value,
                      onChanged: (v) => tipoController.value = v,
                      validator: (v) => v == null ? 'Requerido' : null,
                    ),

                    const SizedBox(height: 20),

                    inputReutilizables(
                      controller: nombreController,
                      nameInput: "Nombre Completo",
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),

                    const SizedBox(height: 20),

                    inputReutilizables(
                      controller: correoController,
                      nameInput: "Correo de Contacto",
                      prefixIcon: const Icon(Icons.alternate_email),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),

                    const SizedBox(height: 20),

                    inputReutilizables(
                      controller: descripcionController,
                      nameInput: "Descripcion detallada",
                      maxLenght: 250,
                      prefixIcon: const Icon(Icons.description_outlined),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading.value ? null : enviarPqrs,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'ENVIAR PQRS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
