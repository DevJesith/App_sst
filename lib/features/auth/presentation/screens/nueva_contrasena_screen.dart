// // features/auth/presentation/screens/recuperar_contrasena_screen.dart

// import 'dart:convert';
// import 'package:crypto/crypto.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import '../../../../../shared/widgets/inputs_widgets.dart';
// import '../../domain/entities/usuarios.dart';
// import '../providers/auth_provider.dart';
// import 'login_screen.dart';

// /// Pantalla simplificada para recuperar contraseña.
// /// El usuario ingresa su email y una nueva contraseña directamente.
// class RecuperarContrasenaScreen extends HookConsumerWidget {
//   const RecuperarContrasenaScreen({super.key});

//   String encriptar(String texto) {
//     final bytes = utf8.encode(texto);
//     final hash = sha256.convert(bytes);
//     return hash.toString();
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final formKey = useMemoized(() => GlobalKey<FormState>());
//     final emailController = useTextEditingController();
//     final newPasswordController = useTextEditingController();
//     final confirmPasswordController = useTextEditingController();
//     final isLoading = useState(false);
//     final obscureText = useState(true);

//     Future<void> recuperar() async {
//       if (!formKey.currentState!.validate()) return;

//       // Validar que las contraseñas coincidan
//       if (newPasswordController.text.trim() != confirmPasswordController.text.trim()) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Las contraseñas no coinciden'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       isLoading.value = true;

//       try {
//         final email = emailController.text.trim();

//         // Verificar si el usuario existe
//         final usuario = await ref.read(
//           obtenerUsuarioPorEmailProvider(email).future,
//         );

//         if (usuario == null) {
//           if (context.mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Este correo no está registrado'),
//                 backgroundColor: Colors.orange,
//               ),
//             );
//           }
//           return;
//         }

//         // Actualizar la contraseña
//         final usuarioActualizado = Usuarios(
//           id: usuario.id,
//           nombre: usuario.nombre,
//           email: usuario.email,
//           contrasena: encriptar(newPasswordController.text.trim()),
//         );

//         await ref.read(actualizarUsuarioProvider(usuarioActualizado).future);

//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('¡Contraseña actualizada exitosamente!'),
//               backgroundColor: Colors.green,
//             ),
//           );

//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => const LoginScreen()),
//           );
//         }
//       } catch (e) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       } finally {
//         isLoading.value = false;
//       }
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       appBar: AppBar(
//         title: const Text('Recuperar contraseña'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final isWide = constraints.maxWidth > 600;

//           return Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//               child: Container(
//                 padding: const EdgeInsets.all(24),
//                 constraints: BoxConstraints(
//                   maxWidth: isWide ? 500 : double.infinity,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 15,
//                       offset: Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: Form(
//                   key: formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       /// Ícono
//                       const Icon(
//                         Icons.lock_reset,
//                         size: 80,
//                         color: CupertinoColors.systemOrange,
//                       ),
//                       const SizedBox(height: 20),

//                       /// Título
//                       const Text(
//                         'Recuperar Contraseña',
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 10),

//                       /// Subtítulo
//                       const Text(
//                         'Ingresa tu correo registrado y crea una nueva contraseña',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.black87,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 30),

//                       /// Campo: Email
//                       inputReutilizables(
//                         controller: emailController,
//                         nameInput: 'Correo electrónico',
//                         validator: (value) {
//                           if (value == null || value.trim().isEmpty) {
//                             return 'Ingresa tu correo';
//                           }
//                           final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//                           if (!emailRegex.hasMatch(value.trim())) {
//                             return 'Correo inválido';
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'ejemplo@correo.com',
//                           prefixIcon: const Icon(Icons.mail_outline),
//                           filled: true,
//                           fillColor: const Color(0xFFF0F2F5),
//                           contentPadding: const EdgeInsets.symmetric(
//                             vertical: 18,
//                             horizontal: 16,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       /// Campo: Nueva Contraseña
//                       inputReutilizables(
//                         controller: newPasswordController,
//                         nameInput: 'Nueva contraseña',
//                         obscuredText: obscureText.value,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Ingresa una contraseña';
//                           }
//                           if (value.length < 6) {
//                             return 'Mínimo 6 caracteres';
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           hintText: '••••••',
//                           prefixIcon: const Icon(Icons.lock_outline),
//                           filled: true,
//                           fillColor: const Color(0xFFF0F2F5),
//                           contentPadding: const EdgeInsets.symmetric(
//                             vertical: 18,
//                             horizontal: 16,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           suffixIcon: IconButton(
//                             onPressed: () =>
//                                 obscureText.value = !obscureText.value,
//                             icon: Icon(
//                               obscureText.value
//                                   ? Icons.visibility_off
//                                   : Icons.visibility,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       /// Campo: Confirmar Contraseña
//                       inputReutilizables(
//                         controller: confirmPasswordController,
//                         nameInput: 'Confirmar contraseña',
//                         obscuredText: obscureText.value,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Confirma tu contraseña';
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           hintText: '••••••',
//                           prefixIcon: const Icon(Icons.lock_outline),
//                           filled: true,
//                           fillColor: const Color(0xFFF0F2F5),
//                           contentPadding: const EdgeInsets.symmetric(
//                             vertical: 18,
//                             horizontal: 16,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 30),

//                       /// Botón
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: isLoading.value ? null : recuperar,
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             backgroundColor: CupertinoColors.systemOrange,
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             elevation: 3,
//                           ),
//                           child: isLoading.value
//                               ? const SizedBox(
//                                   height: 20,
//                                   width: 20,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color: Colors.white,
//                                   ),
//                                 )
//                               : const Text(
//                                   'Actualizar Contraseña',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       /// Ayuda
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.orange.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.info_outline,
//                               color: Colors.orange.shade700,
//                               size: 20,
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 'Solo necesitas tu correo registrado para recuperar tu contraseña',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.orange.shade700,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }