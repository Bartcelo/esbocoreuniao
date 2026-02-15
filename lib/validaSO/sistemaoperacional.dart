import 'dart:io' show Platform;

class ValidaSistema {
  String validaplataforma() {
    if (Platform.isAndroid) {
      return "Android";
    } else if (Platform.isWindows) {
      return "Windows";
    } else if (Platform.isIOS) {
      return "iOS";
    }
    return "Plataforma não encontrada";
  }
}
