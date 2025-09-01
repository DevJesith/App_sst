import 'dart:ffi';

import 'package:app_sst/features/auth/domain/usecases/actualizar_usuario.dart';
import 'package:app_sst/features/auth/domain/usecases/obtener_usuarios.dart';
import 'package:app_sst/features/auth/domain/usecases/validar_codigo_recuperacion.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/entities/usuarios.dart';
import '../../domain/usecases/registrar_usuario.dart';
import '../../domain/usecases/Login_usuario.dart';
import '../../domain/usecases/Verificar_usuario.dart';
import '../../domain/usecases/esta_verificado.dart';
import '../../data/repositories_impl/usuario_repository_impl.dart';
import '../../../../data/database/app_database.dart';

//Repositorio
final usuarioRepositoryProvider = Provider<UsuarioRepositoryImpl>((ref) {
  return UsuarioRepositoryImpl(AppDatabase());
});

//Usecases

final registrarUsuarioUseCaseProvider = Provider<RegistrarUsuario>((ref) {
  final repo = ref.read(usuarioRepositoryProvider);
  return RegistrarUsuario(repo);
});

final loginUsuarioUseCaseProvider = Provider<LoginUsuario>((ref) {
  final repo = ref.read(usuarioRepositoryProvider);
  return LoginUsuario(repo);
});

final verificarUsuarioUseCaseProvider = Provider<VerificarUsuario>((ref) {
  final repo = ref.read(usuarioRepositoryProvider);
  return VerificarUsuario(repo);
});

final estaVerificadoUseCaseProvider = Provider<EstaVerificado>((ref) {
  final repo = ref.read(usuarioRepositoryProvider);
  return EstaVerificado(repo);
});

final actualizarUsuarioUseCaseProvider = Provider<ActualizarUsuario>((ref) {
  final repo = ref.read(usuarioRepositoryProvider);
  return ActualizarUsuario(repo);
});

final obtenerUsuariosUseCaseProvider = Provider<ObtenerUsuarios>((ref) {
  final repo = ref.read(usuarioRepositoryProvider);
  return ObtenerUsuarios(repo);
});

final validarCodigoRecuperacionUseCaseProvider =
    Provider<ValidarCodigoRecuperacion>((ref) {
      final repo = ref.read(usuarioRepositoryProvider);
      return ValidarCodigoRecuperacion(repo);
    });

//Provider que se llamara en la UI

//Registrar usuario

final registrarUsuarioProvider = FutureProvider.family<int, Usuarios>((
  ref,
  usuarios,
) async {
  final usecase = ref.read(registrarUsuarioUseCaseProvider);
  return await usecase(usuarios);
});

//Login

final loginProvider = FutureProvider.family<Usuarios?, Map<String, String>>((
  ref,
  data,
) async {
  final usecase = ref.read(loginUsuarioUseCaseProvider);
  return await usecase(data['email']!, data['contrasena']!);
});

// Verificar usuario
final verificarProvider = FutureProvider.family<bool, String>((
  ref,
  email,
) async {
  final usecase = ref.read(verificarUsuarioUseCaseProvider);
  return await usecase(email);
});

//Saber si esta verificado
final estaVerificadoProvider = FutureProvider.family<bool, String>((
  ref,
  email,
) async {
  final usecase = ref.read(estaVerificadoUseCaseProvider);
  return await usecase(email);
});

final actualizarUsuarioProvider = FutureProvider.family<void, Usuarios>((
  ref,
  usuario,
) async {
  final usecase = ref.read(actualizarUsuarioUseCaseProvider);
  await usecase(usuario);
});

final obtenerTodosUsuariosProvider = FutureProvider<List<Usuarios>>((
  ref,
) async {
  final usecase = ref.read(obtenerUsuariosUseCaseProvider);
  return await usecase();
});

final verificarCodigoProvider = FutureProvider.family<bool, Map<String, String>> ((ref, data) async {
  final usecase = ref.read(validarCodigoRecuperacionUseCaseProvider);
  return await usecase(data['email']!, data['codigo']!);
});