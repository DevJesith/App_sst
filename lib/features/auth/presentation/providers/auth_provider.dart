// features/auth/presentation/providers/auth_provider.dart

import 'package:app_sst/features/auth/domain/usecases/obtener_usuario.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/entities/usuarios.dart';
import '../../data/repositories_impl/usuario_repository_impl.dart';
import '../../domain/usecases/actualizar_usuario.dart';
import '../../domain/usecases/obtener_usuarios_por_email.dart';
import '../../domain/usecases/registrar_usuario.dart';
import '../../domain/usecases/Login_usuario.dart';
import '../../domain/usecases/obtener_usuarios_por_email.dart';

// Provider del repositorio
final usuarioRepositoryProvider = Provider<UsuarioRepositoryImpl>((ref) {
  return UsuarioRepositoryImpl(AppDatabase());
});

// Use Cases Providers
final registrarUsuarioUseCaseProvider = Provider<RegistrarUsuario>((ref) {
  final repo = ref.read(usuarioRepositoryProvider);
  return RegistrarUsuario(repo);
});

final loginUsuarioUseCaseProvider = Provider<LoginUsuario>((ref) {
  final repo = ref.read(usuarioRepositoryProvider);
  return LoginUsuario(repo);
});

final actualizarUsuarioUseCaseProvider = Provider<ActualizarUsuario>((ref) {
  final repo = ref.read(usuarioRepositoryProvider);
  return ActualizarUsuario(repo);
});

final obtenerUsuariosUseCaseProvider = Provider<ObtenerUsuarios>((ref) {
  final repo = ref.read(usuarioRepositoryProvider);
  return ObtenerUsuarios(repo);
});

final obtenerUsuarioPorEmailUseCaseProvider = Provider<ObtenerUsuarioPorEmail>((ref) {
  final repo = ref.read(usuarioRepositoryProvider);
  return ObtenerUsuarioPorEmail(repo);
});

// Providers para la UI
final registrarUsuarioProvider = FutureProvider.family<int, Usuarios>((ref, usuarios) async {
  final usecase = ref.read(registrarUsuarioUseCaseProvider);
  return await usecase(usuarios);
});

final loginProvider = FutureProvider.family<Usuarios?, Map<String, String>>((ref, data) async {
  final usecase = ref.read(loginUsuarioUseCaseProvider);
  return await usecase(data['email']!, data['contrasena']!);
});

final actualizarUsuarioProvider = FutureProvider.family<void, Usuarios>((ref, usuario) async {
  final usecase = ref.read(actualizarUsuarioUseCaseProvider);
  await usecase(usuario);
});

final obtenerTodosUsuariosProvider = FutureProvider<List<Usuarios>>((ref) async {
  final usecase = ref.read(obtenerUsuariosUseCaseProvider);
  return await usecase();
});

final obtenerUsuarioPorEmailProvider = FutureProvider.family<Usuarios?, String>((ref, email) async {
  final usecase = ref.read(obtenerUsuarioPorEmailUseCaseProvider);
  return await usecase(email);
});

//provider para mentener el usuario autenticsado en la sesion
final usuarioAutenticadoProvider = StateProvider<Usuarios?>((ref) => null);