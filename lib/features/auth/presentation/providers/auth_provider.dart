// features/auth/presentation/providers/auth_provider.dart

import 'package:app_sst/features/auth/domain/usecases/obtener_usuario.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../data/database/app_database.dart';
import '../../domain/entities/usuarios.dart';
import '../../data/repositories_impl/usuario_repository_impl.dart';
import '../../domain/usecases/actualizar_usuario.dart';
import '../../domain/usecases/obtener_usuarios_por_email.dart';
import '../../domain/usecases/registrar_usuario.dart';
import '../../domain/usecases/login_usuario.dart';

// -----------------------------------------------------------
// 1. CAPA DE DATOS
// -----------------------------------------------------------

/// Provider que expone la instacion unica de la base de datos.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Provider del repositorio
/// Recibe la base de datos e implementa la logica de acceso a datos de usuarios
final usuarioRepositoryProvider = Provider<UsuarioRepositoryImpl>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return UsuarioRepositoryImpl(db);
});

// -----------------------------------------------------------
// 2. CAPA DE DOMINIO (CASOS DE USO)
// -----------------------------------------------------------

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

// -----------------------------------------------------------
// 3. CAPA DE PRESENTACION (UI y Logica)
// -----------------------------------------------------------

/// Ejecuta el registro de un usuario
/// Retorna el ID del nuevo usuario
final registrarUsuarioProvider = FutureProvider.family<int, Usuarios>((ref, usuarios) async {
  final usecase = ref.read(registrarUsuarioUseCaseProvider);
  return await usecase(usuarios);
});

/// Ejecuta el login
/// Recibe un Map con 'email' y 'contraseña'.
final loginProvider = FutureProvider.family<Usuarios?, Map<String, String>>((ref, data) async {
  final usecase = ref.read(loginUsuarioUseCaseProvider);
  return await usecase(data['email']!, data['contrasena']!);
});


/// Ejecuta la actualizacvion de datos del usuario.
final actualizarUsuarioProvider = FutureProvider.family<void, Usuarios>((ref, usuario) async {
  final usecase = ref.read(actualizarUsuarioUseCaseProvider);
  await usecase(usuario);
});


/// Obtiene la lista de todos los usuarios registrados.
final obtenerTodosUsuariosProvider = FutureProvider<List<Usuarios>>((ref) async {
  final usecase = ref.read(obtenerUsuariosUseCaseProvider);
  return await usecase();
});


/// Busca un usuario por su email
final obtenerUsuarioPorEmailProvider = FutureProvider.family<Usuarios?, String>((ref, email) async {
  final usecase = ref.read(obtenerUsuarioPorEmailUseCaseProvider);
  return await usecase(email);
});

// -----------------------------------------------------------
// 4. ESTADO GLOBAL DE SESION
// -----------------------------------------------------------

/// Mantiene el estado del usuario autenticado actualmente en la aplicacion
/// Si es null, no hay sesion activa.
final usuarioAutenticadoProvider = StateProvider<Usuarios?>((ref) => null);