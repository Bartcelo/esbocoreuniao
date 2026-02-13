import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoService {
  // Singleton para não criar múltiplas instâncias
  static final AppInfoService _instance = AppInfoService._internal();
  factory AppInfoService() => _instance;
  AppInfoService._internal();

  // Cache das informações para não buscar toda hora
  PackageInfo? _cachedInfo;

  // Método principal para buscar as informações
  Future<PackageInfo> getInfo() async {
    if (_cachedInfo != null) return _cachedInfo!;

    _cachedInfo = await PackageInfo.fromPlatform();
    return _cachedInfo!;
  }

  // Método para limpar o cache se necessário
  void clearCache() {
    _cachedInfo = null;
  }

  // Método para mostrar o diálogo com as informações
  Future<void> showInfoDialog(BuildContext context) async {
    // Verificação de segurança
    if (!context.mounted) return;

    try {
      // Busca as informações (usa cache se disponível)
      final info = await getInfo();

      if (!context.mounted) return;

      // Mostra o diálogo
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Informações do App'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('App', info.appName),
              _buildInfoRow('Versão', info.version),
              _buildInfoRow('Build', info.buildNumber),
              _buildInfoRow('Pacote', info.packageName),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao buscar versão: $e')));
    }
  }

  // Método utilitário para formatar as linhas de informação
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Método para obter apenas a versão como String (se precisar)
  Future<String> getVersaoString() async {
    final info = await getInfo();
    return '${info.version} (build ${info.buildNumber})';
  }
}
