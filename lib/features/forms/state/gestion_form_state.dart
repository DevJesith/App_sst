import 'package:image_picker/image_picker.dart';

class GestionFormState {
  final String? proyecto;
  final List<XFile> imagenes;

  const GestionFormState({this.proyecto, this.imagenes = const []});

  GestionFormState copyWith({String? proyecto, List<XFile>? imagenes}) {
    return GestionFormState(
      proyecto: proyecto ?? this.proyecto,
      imagenes: imagenes ?? this.imagenes,
    );
  }
}
