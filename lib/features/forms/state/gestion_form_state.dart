import 'package:image_picker/image_picker.dart';

/// Estado del formulario de gestión.
/// Contiene el proyecto y una lista de imágenes seleccionadas.

class GestionFormState {
  final String? proyecto;
  final List<XFile> imagenes;

  const GestionFormState({this.proyecto, this.imagenes = const []});

  /// Crea una nueva instancia con los valores actualizados.

  GestionFormState copyWith({String? proyecto, List<XFile>? imagenes}) {
    return GestionFormState(
      proyecto: proyecto ?? this.proyecto,
      imagenes: imagenes ?? this.imagenes,
    );
  }
}
