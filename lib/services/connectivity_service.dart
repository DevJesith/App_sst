import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static Future<bool> tieneInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
